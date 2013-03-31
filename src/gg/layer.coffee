#<< gg/util

class gg.Layers
    constructor: (@g, @spec) ->
      @layers = []
      @parseSpec()

    parseSpec: ->
      _.each @spec, (layerspec) => @addLayer layerspec

    # @return [ [node,...], ...] a list of nodes for each layer
    compile: -> _.map @layers, (l) -> l.compile()

    getLayer: (layerIdx) ->
      if layerIdx >= @layers.length
        throw Error("Layer with idx #{layerIdx} does not exist.
          Max layer is #{@layers.length}")
      @layers[layerIdx]
    get: (layerIdx) -> @getLayer layerIdx

    addLayer: (layerOrSpec) ->
      layerIdx = @layers.length

      if _.isSubclass layerOrSpec, gg.Layer
        layer = layerOrSpec
      else
        spec = _.clone layerOrSpec
        spec.layerIdx = layerIdx
        layer = gg.Layer.fromSpec @g, spec

      layer.layerIdx = layerIdx
      @layers.push layer





class gg.Layer
  constructor: (@g, @spec={}) ->
    # which index in the specification
    @layerIdx = @spec.layerIdx if @spec.layerIdx?
    @type = "layer"
    @name = findGood [@spec.name, "node-#{@id}"]

    @parseSpec()
  @id: -> gg.wf.Node::_id += 1
  _id: 0


  parseSpec: -> null

  @fromSpec: (g, spec) ->
    if _.isArray spec
      throw Error("layer currently only supports shorthand style")
    else
      new gg.LayerShorthand g, spec



class gg.LayerShorthand extends gg.Layer
  constructor: (@g, @spec={}) ->
    @type = "layershort"
    super


  # TODO: merge pre and post stats aesthetic mappings so we can train properly
  #       currently only supports pre-stats mapping
  aesthetics: ->
    subSpecs = [@mapSpec, @geomSpec, @statSpec, @posSpec]
    aess = _.uniq _.compact _.union(_.map subSpecs, (s) -> _.keys(s.aes))
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
    mapSpec  = findGoodAttr spec, ['aes', 'aesthetic', 'mapping'], {}
    @mapSpec = {aes: mapSpec, name: "map-shorthand"}
    @labelSpec = {key: "layer", val: @layerIdx}

    @geom = gg.Geom.fromSpec @, @geomSpec
    @stat = gg.Stat.fromSpec @, @statSpec
    @pos = gg.Position.fromSpec @, @posSpec
    @map = new gg.Mapper @g, @mapSpec
    @labelNode = new gg.wf.Label @labelSpec

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
      else
        [[], "identity"]

    subSpec = findGoodAttr spec, aliases, defaultType

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
    nodes = []

    # pre-stats transforms
    nodes.push new gg.wf.Stdout {name: "initial data", n: 1}
    nodes.push @labelNode
    nodes.push @map


    # Statistics transforms
    nodes.push @g.scales.prestatsNode
    nodes.push @stat

    # facet join -- add facetX/Y columns to table
    nodes.push @g.facets.labelerNodes()

    #####
    # Geometry Part of Workflow
    #####

    # geom: map attributes to aesthetic names
    # scales: train scales after the final aesthetic mapping (inputs are data values)
    nodes.push new gg.wf.Stdout {name: "pre-geom", n: 1}
    nodes.push @geom.map
    nodes.push @g.scales.pregeomNode
    nodes.push new gg.wf.Stdout {name: "post-geom", n: 1}

    # Rendering
    # layout the overall graphic, allocate space for facets
    # facets: allocate containers and compute ranges for the scales
    nodes.push @g.layoutNode()
    nodes.push @g.facets.allocatePanesNode()

    # geom: facets have set the ranges so transform data values to pixel values
    # geom: map minimum attributes (x,y) to base attributes (x0, y0, x1, y1)
    # geom: position transformation
    nodes.push new gg.wf.Stdout {name: "pre-pixel", n: 1}
    nodes.push @geom.applyScales
    nodes.push @geom.reparam
    nodes.push @pos
    nodes.push new gg.wf.Stdout {name: "post:pixel", n: 1}

    # facets: retrain scales after positioning (jitter) (inputs are pixel values)
    nodes.push @g.scales.prerenderNode

    # coord: pixel -> domain -> transformed -> pixel XXX: not implemented


    # render: render geometries
    nodes.push new gg.wf.Stdout {name: "position pixel", n: 1}
    nodes.push @geom.render

    nodes = @compileNodes nodes
    console.log "returing nodes"
    nodes

  compileNodes: (nodes) ->
    nodes = _.map _.compact(nodes), (node) ->
      if _.isSubclass node, gg.XForm
        node.compile()
      else
        node
    _.compact _.flatten nodes






class gg.LayerArray
  xformToString: (xform) ->
    if _.isSubclass xform, gg.Stat
      "S"
    else if _.isSubclass xform, gg.Mapper
      "M"
    else if _.isSubclass xform, gg.Position
      "P"
    else if _.isSubclass xform, gg.GeomRender
      "R"
    else if _.isSubclass xform, gg.Geom
      "G"

  parseArraySpec: (spec) ->
    # Explicit list of transformations
    # ensure that the list ends with geom/render nodes
    @xforms = _.map spec, (xformspec) -> gg.XForm.fromSpec xformspec
    klasses = _.map @xforms, (xform) => @xformToString xform
    klassStr = klasses.join ""
    validregex = /^([MS]*)(G|(?:M?P?R))$/
    unless regex.test klassStr
      throw Error("Layer: series of XForms not valid (#{klassStr})")

    [entireStr, statChars, geomChars] = validregex.exec(klassStr)
    [sidx, eidx] = [s, statChars.length()]
    @stats = @xforms[sidx...eidx]
    [sidx, eidx] = [eidx, eidx+geomChars.length()]
    throw Error("gg.Geom.parseArraySpec: not implemented. Needs to be thought through")
    @geoms = @xforms[sidx...eidx]
    if geomChars is "G"
      geom = @geoms[0]
      @geoms = [geom.mappingXForm(), geom.positionXForm()]
      @renders = [geom.renderXForm()]
    else
      @renders = [_.last @geoms]
      @geoms = _.initial @geoms


