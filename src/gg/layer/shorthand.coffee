#<< gg/layer/layer

class gg.layer.Shorthand extends gg.layer.Layer
  constructor: (@g, @spec={}) ->
    @type = "layershort"
    super


  # TODO: merge pre and post stats aesthetic mappings so we can train properly
  #       currently only supports pre-stats mapping
  aestheticsFromSpec: (spec) ->
    aess = _.keys spec
    nestedAess = _.map spec, (v, k) ->
      if _.isObject(v) and not _.isArray(v)
        _.keys v
      else
        null
    aess = _.compact _.flatten _.union(aess, nestedAess)
    aess

  aesthetics: ->
    subSpecs = [@mapSpec, @geomSpec, @statSpec, @posSpec]
    aess = _.uniq _.compact _.union(_.map subSpecs, (s) => @aestheticsFromSpec s.aes)
    aess = _.map aess, (aes) ->
      if aes in gg.scale.Scale.xs
        gg.scale.Scale.xs
      else if aes in gg.scale.Scale.ys
        gg.scale.Scale.ys
      else
        aes
    aess = _.uniq _.flatten aess
    aess


  #
  # spec:
  #
  # {
  #  geom: geomspec
  #  pos: posspec
  #  stat: statspec
  #  map: {}
  # }
  #
  # geomspec/posspec/statspec:
  #
  # {
  #  type: ""
  #  aes: { ..., group: 1 }
  #  param/args: {}
  #  name: "...-shorthand"
  # }
  #
  # map is a pre-stats mapping, if desired (for compatibility with ggplot2)
  # it can be replicated by adding an aes attribute to statspec
  #
  parseSpec: ->
    spec = @spec

    @geomSpec = @extractSpec "geom"
    @statSpec = @extractSpec "stat"
    @posSpec  = @extractSpec "pos"
    mapSpec  = _.findGoodAttr spec, ['aes', 'aesthetic', 'mapping'], {}
    @mapSpec = {aes: mapSpec, name: "map-shorthand"}
    @coordSpec = @extractSpec "coord"
    @coordSpec.name = "coord-#{@layerIdx}"
    @labelSpec = {key: "layer", val: @layerIdx}


    @geom = gg.geom.Geom.fromSpec @, @geomSpec
    @stat = gg.stat.Stat.fromSpec @, @statSpec
    @pos = gg.pos.Position.fromSpec @, @posSpec
    @map = gg.xform.Mapper.fromSpec @g, @mapSpec
    @labelNode = new gg.wf.Label @labelSpec
    @coord = gg.coord.Coordinate.fromSpec @, @coordSpec

    console.log "### layer parsed xforms ###"
    console.log @stat.constructor.name
    console.log @geom.constructor.name
    console.log @pos.constructor.name
    console.log @map.constructor.name if @map?


    @pos = null if _.isSubclass @pos, gg.pos.Identity

    super



  # extract the geom/stat/pos specific spec from
  # the shorthand spec
  #
  # @param xform geom/stat/pos
  # @param spec  defaults to @spec
  # @return consistently formatted sub-spec of the form
  #         { type: , aes:, param: }
  extractSpec: (xform, spec=null) ->
    spec = @spec unless spec?

    [aliases, defaultType] = switch xform
      when "geom"
        [['geom', 'geometry'], "point"]
      when "stat"
        [['stat', 'stats', 'statistic'], "identity"]
      when "pos"
        [["pos", "position"], "identity"]
      when "coord"
        [["coord", "coordinate", "coordinates"], "identity"]
      else
        [[], "identity"]


    subSpec = _.findGoodAttr spec, aliases, defaultType

    console.log "layer.extractSpec got subspec for #{xform}:  #{JSON.stringify subSpec}"

    if _.isString subSpec
      subSpec =
        type: subSpec
        aes: {}
        param: {}
    else
      subSpec.aes = {} unless subSpec.aes?
      subSpec.param = {} unless subSpec.param?

    subSpec.name = "#{xform}-shorthand" unless subSpec.name?
    subSpec

  compile: ->
    console.log "layer.compile called"
    debugaess = ['x', 'r', 'y', 'y0', 'y1', "stroke", "stroke-width"]
    debugaess = ['x', 'y', 'q1', 'q3', 'median']
    nodes = []

    # pre-stats transforms
    nodes.push new gg.wf.Stdout {name: "initial data", n: 1}
    nodes.push @labelNode
    nodes.push @map


    # Statistics transforms
    nodes.push @g.scales.prestats
    nodes.push new gg.wf.Scales
      name: "pre-stat-#{@layerIdx}"
      scales: @g.scales
    nodes.push @stat
    nodes.push new gg.wf.Stdout
      name: "post-stat-#{@layerIdx}"
      n: 5
      aess: debugaess


    # facet join -- add facetX/Y columns to table
    nodes.push @g.facets.labelerNodes()

    #####
    # Geometry Part of Workflow
    #####

    # geom: map attributes to aesthetic names
    # scales: train scales after the final aesthetic mapping (inputs are data values)
    #nodes.push new gg.wf.Stdout {name: "pre-geom-map", n: 1}
    nodes.push @geom.map
    nodes.push new gg.wf.Stdout
      name: "pre-geomtrain-#{@layerIdx}"
      n: 5
      aess: debugaess


    #nodes.push new gg.wf.Stdout {name: "post-geom-map", n: 1}
    nodes.push @g.scales.postgeommap
    nodes.push new gg.wf.Stdout
      name: "post-geommaptrain-#{@layerIdx}"
      n: 5
      aess: debugaess
    nodes.push new gg.wf.Scales
      name: "post-geommaptrain-#{@layerIdx}"
      scales: @g.scales

    # Rendering
    # layout the overall graphic, allocate space for facets
    # facets: allocate containers and compute ranges for the scales
    nodes.push @g.layoutNode()
    nodes.push @g.facets.allocatePanesNode()

    # geom: facets have set the ranges so transform data values to pixel values
    # geom: map minimum attributes (x,y) to base attributes (x0, y0, x1, y1)
    # geom: position transformation
    nodes.push new gg.wf.Stdout
      name: "pre-scaleapply-#{@layerIdx}"
      n: 5
      aess: debugaess
    nodes.push new gg.xform.ScalesApply @,
      posMapping: @geom.posMapping()
    nodes.push new gg.wf.Stdout
      name: "post-scaleapply-#{@layerIdx}"
      n: 5
      aess: debugaess


    #nodes.push new gg.wf.Stdout {name: "pre-reparam", n: 5}
    nodes.push @geom.reparam
    nodes.push new gg.wf.Stdout
      name: "post-reparam-#{@layerIdx}"
      n: 5
      aess: debugaess

    #nodes.push new gg.wf.Stdout {name: "post-reparam", n: 5}
    nodes.push @pos
    nodes.push new gg.wf.Stdout
      name: "post-position-#{@layerIdx}"
      n: 5
      aess: debugaess

    # scales: retrain scales after positioning (jitter)
    #         (inputs are pixel values)
    if @pos?
      nodes.push new gg.wf.Scales
        name: "prepixeltrain scale"
        scales: @g.scales

      nodes.push @g.scales.trainpixel

      nodes.push new gg.wf.Stdout
        name: "post-pixeltrain"
        n: 5
        aess: debugaess



    # coord: pixel -> domain -> transformed -> pixel XXX: not implemented
    nodes.push new gg.wf.Scales
      name: "pre-coord"
      scales: @g.scales
    nodes.push @coord

    nodes.push new gg.wf.Stdout
      name: "post-coord-#{@layerIdx}"
      n: 5
      aess: debugaess



    # render: render axes
    nodes.push @g.facets.renderAxesNode()

    # render: render geometries
    nodes.push @geom.render

    nodes = @compileNodes nodes
    console.log "returing nodes"
    nodes

  compileNodes: (nodes) ->
    nodes = _.map _.compact(_.flatten nodes), (node) ->
      if _.isSubclass node, gg.core.XForm
        node.compile()
      else
        node
    _.compact _.flatten nodes





