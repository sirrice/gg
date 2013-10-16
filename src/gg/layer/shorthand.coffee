#<< gg/layer/layer

class gg.layer.Shorthand extends gg.layer.Layer
  @ggpackage = "gg.layer.Shorthand"

  constructor: (@g, @spec={}) ->
    super

    @type = "layershort"
    @log = gg.util.Log.logger @constructor.ggpackage, "Layer-#{@layerIdx}"


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
    @setupGeom()
    @setupStats()
    @setupPos()
    @setupMap()
    @setupCoord()
    super


  setupGeom: ->
    @geomSpec = @extractSpec "geom"
    @geomSpec.name = "#{@geomSpec.name}-#{@layerIdx}"
    @geom = gg.geom.Geom.fromSpec @, @geomSpec

  setupStats: ->
    @statSpec = @extractSpec "stat"
    if _.isArray @statSpec
      @stats = _.map @statSpec, (@subSpec) ->
        gg.stat.Stat.fromSpec @subSpec
    else
      @stats = [gg.stat.Stat.fromSpec @statSpec]

  setupPos: ->
    @posSpec  = @extractSpec "pos"
    if _.isArray @posSpec
      @pos = _.map @posSpec, (@subSpec) ->
        gg.pos.Position.fromSpec @subSpec
    else
      @pos = [gg.pos.Position.fromSpec @posSpec]

  setupMap: ->
    mapSpec  = _.findGoodAttr @spec, ['aes', 'aesthetic', 'mapping'], {}
    mapSpec = _.extend(_.clone(@g.aesspec), mapSpec)
    @mapSpec = {aes: mapSpec, name: "map-shorthand-#{@layerIdx}"}
    @map = gg.xform.Mapper.fromSpec @mapSpec

  setupCoord: ->
    @coordSpec = @extractSpec "coord"
    @coordSpec.name = "coord-#{@layerIdx}"
    @coord = gg.coord.Coordinate.fromSpec @coordSpec


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

    defaultAes = {}
    subSpec = _.findGoodAttr spec, aliases, defaultType
    @log "extractSpec xform: #{xform}\tspec: #{JSON.stringify subSpec}"

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

  makeStdOut: (name, params) ->
    arg = _.clone params
    params =
      n: 5
      aess: null
    _.extend params, arg
    new gg.wf.Stdout
      name: "#{name}-#{@layerIdx}"
      params: params

  makeScalesOut: (name) ->
    new gg.wf.Scales
      name: "#{name}-#{@layerIdx}"


  compile: ->
    @log "compile()"
    nodes = []

    # add environment variables
    addenv = gg.xform.Mapper.fromSpec
      name: "layer labeler"
      aes:
        layer: () => @layerIdx
        posMapping: () => @geom.posMapping()
    nodes.push addenv

    nodes.push @compilePrestats()
    nodes.push @compileStats()

    nodes.push @compileGeomMap()
    nodes.push new gg.xform.ScalesValidate
      name: 'scales-validate'
    nodes.push @compileInitialLayout()

    nodes.push @compileGeomReparam()
    nodes.push @compileGeomPos()
    nodes.push @compileCoord()
    nodes.push @compileRender()

    nodes = @compileNodes nodes
    nodes



  compilePrestats: ->
    nodes = [
      @makeStdOut "init-data"
      @map
      @makeStdOut "post-map-#{@layerIdx}"
      new gg.xform.ScalesSchema
        name: "scales-schema-#{@layerIdx}"
        params:
          config: @g.scales.scalesConfig
      @makeStdOut "post-scaleschema"

    ]
    nodes

  compileStats: ->
    nodes = []

    # train & filter scales
    nodes.push @g.scales.prestats
    nodes.push @makeStdOut "post-train"
    nodes.push new gg.xform.ScalesFilter
      name: "scalesfilter-#{@layerIdx}"
      params:
        posMapping: @geom.posMapping()
    nodes.push @makeStdOut "post-scalefilter-#{@layerIdx}"
    nodes.push @makeScalesOut "pre-stat-#{@layerIdx}"

    # run the stat functions
    nodes.push @stats
    nodes.push @makeStdOut "post-stat-#{@layerIdx}"
    nodes


  compileGeomMap: ->
    nodes = []

    #
    # Geometry Part of Workflow #
    #

    # geom: map attributes to aesthetic names
    # scales: train scales after the final aesthetic mapping (inputs are data values)
    #nodes.push new gg.wf.Stdout {name: "pre-geom-map", n: 1}
    nodes.push @geom.map
    nodes.push @makeStdOut "pre-geomtrain-#{@layerIdx}"


    #nodes.push new gg.wf.Stdout {name: "post-geom-map", n: 1}
    nodes.push @g.scales.postgeommap
    nodes.push @makeStdOut "post-geommaptrain"
    nodes.push @makeScalesOut "post-geommaptrain"

    nodes

  compileInitialLayout: ->
    nodes = []


    # layout the overall graphic, allocate space for facets
    # facets: allocate containers and compute ranges for the scales
    nodes.push @g.layoutNode
    nodes.push @g.facets.layout1
    #nodes.push @g.facets.layout1rpc

    # geom: facets have set the ranges so transform data values to 
    #       pixel values
    # geom: map minimum attributes (x,y) to base attributes (x0, y0, x1, y1)
    # geom: position transformation
    nodes.push @g.facets.trainer
    nodes.push @makeScalesOut "pre-scaleapply"
    nodes.push new gg.xform.ScalesApply
      name: "scalesapply-#{@layerIdx}"
      params:
        posMapping: @geom.posMapping()
    nodes.push @makeStdOut "post-scaleapply"
    nodes


  compileGeomReparam: ->
    nodes = []
    nodes.push @geom.reparam
    nodes.push @makeStdOut "post-reparam"
    nodes

  compileGeomPos: ->
    nodes = []

    if @pos? and @pos.length > 0
      nodes.push @pos
      nodes.push @makeStdOut "post-position"

      nodes.push @g.scales.pixel
      nodes.push @makeStdOut "post-pixeltrain"

      # reconfigure the layout after positioning
      nodes.push @g.facets.layout2

    nodes


  compileCoord: ->
    nodes = []
    # coord: pixel -> domain -> transformed -> pixel
    # XXX: not implemented
    nodes.push @makeScalesOut "pre-coord"
    nodes.push @coord
    nodes.push @makeStdOut "post-coord"
    nodes

  #
  # Rendering Nodes are all Client only
  #
  # render: render axes
  compileRender: ->
    nodes = []
    nodes.push @g.renderNode
    nodes.push @g.facets.render
    nodes.push @g.facets.renderPanes()

    # render: render geometries
    nodes.push @makeStdOut "pre-render"
      location: "client"
    nodes.push @geom.render
    nodes




  compileNodes: (nodes) ->
    nodes = _.map _.compact(_.flatten nodes), (node) ->
      if _.isSubclass node, gg.core.XForm
        node.compile()
      else
        node
    _.compact _.flatten nodes





