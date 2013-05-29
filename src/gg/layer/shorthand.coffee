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
    @geomSpec.name = "#{@geomSpec.name}-#{@layerIdx}"
    @statSpec = @extractSpec "stat"
    @posSpec  = @extractSpec "pos"
    mapSpec  = _.findGoodAttr spec, ['aes', 'aesthetic', 'mapping'], {}
    mapSpec = _.extend(_.clone(@g.aesspec), mapSpec)
    @mapSpec = {aes: mapSpec, name: "map-shorthand-#{@layerIdx}"}
    @coordSpec = @extractSpec "coord"
    @coordSpec.name = "coord-#{@layerIdx}"
    @labelSpec = {key: "layer", val: @layerIdx}
    @groupSpec = "group" if "group" of @mapSpec.aes


    @geom = gg.geom.Geom.fromSpec @, @geomSpec
    @stat = gg.stat.Stat.fromSpec @, @statSpec
    @pos = gg.pos.Position.fromSpec @, @posSpec
    @map = gg.xform.Mapper.fromSpec @g, @mapSpec
    @labelNode = new gg.wf.EnvPush @labelSpec
    @coord = gg.coord.Coordinate.fromSpec @, @coordSpec
    if "group" of @mapSpec.aes
      @groupby = gg.xform.Split.createNode "group", "group"
      @groupbylabel = new gg.wf.Join#EnvGet
        name: "groupbylabel-#{@layerIdx}"
        key: "group"

    #@pos = null if _.isSubclass @pos, gg.pos.Identity

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

    @log "extractSpec: xform: #{xform}\tspec: #{JSON.stringify subSpec}"
    defaultAes = _.clone @g.aesspec

    if _.isString subSpec
      subSpec =
        type: subSpec
        aes: defaultAes
        param: {}
    else
      subSpec.aes = _.extend defaultAes, subSpec.aes
      subSpec.param = {} unless subSpec.param?

    subSpec.name = "#{xform}-shorthand-#{@layerIdx}" unless subSpec.name?
    subSpec

  compile: ->
    @log "compile()"
    debugaess = ['x', 'y', 'q1', 'q3', 'median']
    debugaess = ['x', 'group', 'stroke']
    debugaess = null
    makeStdOut = (name, n=5, aess=debugaess) =>
      new gg.wf.Stdout
        name: "#{name}-#{@layerIdx}"
        n: 5
        aess: aess
      #null

    makeScalesOut = (name, scales=@g.scales) =>
      new gg.wf.Scales
        name: "#{name}-#{@layerIdx}"
        scales: scales
      null



    nodes = []

    # pre-stats transforms
    nodes.push makeStdOut "init-data"
    nodes.push @labelNode
    nodes.push @map
    nodes.push @groupby


    # Statistics transforms
    nodes.push @g.scales.prestats
    nodes.push makeStdOut "post-train"
    nodes.push new gg.xform.ScalesFilter @,
      name: "scalesfilter-#{@layerIdx}"
      posMapping: @geom.posMapping()
    nodes.push makeScalesOut "pre-stat-#{@layerIdx}"
    nodes.push @stat
    nodes.push makeStdOut "post-stat-#{@layerIdx}"


    # facet join -- add facetX/Y columns to table
    nodes.push @g.facets.labelerNodes()
    nodes.push makeStdOut "post-facetLabel-#{@layerIdx}"
    nodes.push @groupbylabel
    nodes.push makeStdOut "post-groupby-#{@layerIdx}"

    # Geometry Part of Workflow #

    # geom: map attributes to aesthetic names
    # scales: train scales after the final aesthetic mapping (inputs are data values)
    #nodes.push new gg.wf.Stdout {name: "pre-geom-map", n: 1}
    nodes.push @geom.map
    nodes.push makeStdOut "pre-geomtrain-#{@layerIdx}"


    #nodes.push new gg.wf.Stdout {name: "post-geom-map", n: 1}
    nodes.push @g.scales.postgeommap
    nodes.push makeStdOut "post-geommaptrain"
    nodes.push makeScalesOut "post-geommaptrain"



    # Rendering
    # layout the overall graphic, allocate space for facets
    # facets: allocate containers and compute ranges for the scales
    nodes.push @g.layoutNode()
    nodes.push @g.facets.allocatePanesNode()


    # geom: facets have set the ranges so transform data values to pixel values
    # geom: map minimum attributes (x,y) to base attributes (x0, y0, x1, y1)
    # geom: position transformation
    nodes.push @g.facets.trainerNode()
    nodes.push makeStdOut "pre-scaleapply"
    nodes.push new gg.xform.ScalesApply @,
      name: "scalesapply-#{@layerIdx}"
      posMapping: @geom.posMapping()
    nodes.push makeStdOut "post-scaleapply"


    nodes.push @geom.reparam
    nodes.push makeStdOut "post-reparam"


    if @pos?
      nodes.push @pos
      nodes.push makeStdOut "post-position"

      # reconfigure the layout after positioning
      nodes.push @g.facets.reallocatePanesNode()

      nodes.push @g.scales.pixel


    # coord: pixel -> domain -> transformed -> pixel XXX: not implemented
    nodes.push makeScalesOut "pre-coord"
    nodes.push @coord
    nodes.push makeStdOut "post-coord"


    # render: render axes
    nodes.push @g.facets.renderAxesNode()

    # render: render geometries
    nodes.push @geom.render


    nodes = @compileNodes nodes
    nodes

  compileNodes: (nodes) ->
    nodes = _.map _.compact(_.flatten nodes), (node) ->
      if _.isSubclass node, gg.core.XForm
        node.compile()
      else
        node
    _.compact _.flatten nodes





