#<< gg/layer/layer

class gg.layer.Shorthand extends gg.layer.Layer
  @ggpackage = "gg.layer.Shorthand"

  constructor: (@g, @spec={}) ->
    super

    @type = "layershort"
    @log = gg.util.Log.logger @constructor.ggpackage, "Layer-#{@layerIdx}"


  parseSpec: ->
    @setupGeom()
    @setupStats()
    @setupPos()
    @setupMap()
    @setupCoord()
    super


  setupGeom: ->
    @geomSpec = @spec.geom
    @geomSpec.name = "#{@geomSpec.name}-#{@layerIdx}"
    @geom = gg.geom.Geom.fromSpec @, @geomSpec

  setupStats: ->
    @statSpec = @spec.stat
    @statSpec = _.flatten [@statSpec]
    @stats = _.map @statSpec, (subSpec, idx) =>
      subSpec.name = "stat-#{subSpec.type}-#{@layerIdx}"
      gg.stat.Stat.fromSpec subSpec
    @stats

  setupPos: ->
    @posSpec  = @spec.pos
    @posSpec = _.flatten [@posSpec]
    @pos = _.map @posSpec, (subSpec) =>
      subSpec.name = "pos-#{subSpec.type}-#{@layerIdx}"
      gg.pos.Position.fromSpec subSpec
    @pos

  setupMap: ->
    console.log @spec
    aes = @spec.aes
    @group = gg.xform.Mapper.groupSpec aes
    unless 'group' of aes
      aes.group = @group.group

    # XXX: infer if a mapping is for a constant and
    #      set the scales to identity (if not already set)

    @detectscales = new gg.xform.DetectScales
      name: "detectscales"
      params:
        aes: aes

    @mapSpec = 
      aes: aes
      name: "map-shorthand-#{@layerIdx}"
    @map = gg.xform.Mapper.fromSpec @mapSpec

  setupCoord: ->
    @coordSpec = @spec.coord
    @coordSpec.name = "coord-#{@layerIdx}"
    @coord = gg.coord.Coordinate.fromSpec @coordSpec

  makeStdOut: (name, params) ->
    arg = _.clone params
    params =
      n: 5
      cols: ['layer', 'group', 'fill', 'x', 'y']
    _.extend params, arg
    new gg.wf.Stdout
      name: "#{name}-#{@layerIdx}"
      params: params

  makeScalesOut: (name) ->
    new gg.wf.Scales
      name: "#{name}-#{@layerIdx}"

  makeEnvSetup: ->
    gg.wf.SyncBlock.create ((pt, params) ->
      [t, md] = [pt.left(), pt.right()]
      layerIdx = params.get 'layer'
      posMapping = params.get 'posMapping'
      t = t.setColVal 'layer', layerIdx
      md = md.setColVal 'layer', layerIdx
      md = md.setColVal 'posMapping', posMapping
      new data.PairTable t, md), {
        layer: @layerIdx
        posMapping: @geom.posMapping()
      }, 'layer-labeler'


  compile: ->
    @log "compile()"
    nodes = []

    nodes.push @compileSetup()
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



  compileSetup: ->
    [
      @makeEnvSetup()
      @map
      @detectscales
      new gg.xform.ScalesSchema
        name: "scales-schema-#{@layerIdx}"
        params:
          config: @g.scales.scalesConfig
      @g.facets.labeler
    ]

  compileStats: ->

    [
      # train & filter scales
      @g.scales.prestats

      new gg.xform.ScalesFilter
        name: "scalesfilter-#{@layerIdx}"
        params:
          posMapping: @geom.posMapping()
          config: @g.scales.scalesConfig
      @makeStdOut "post-scalefilter-#{@layerIdx}"
      @makeScalesOut "pre-stat-#{@layerIdx}"

      # run the stat functions
      @stats
    ]


  compileGeomMap: ->
    [
      @geom.map
      @g.scales.postgeommap
      @makeStdOut "post-geommaptrain"
      @makeScalesOut "post-geommaptrain"
    ]

  compileInitialLayout: ->
    [
      @g.layoutNode
      @g.facets.layout1
      @g.facets.trainer

      @makeScalesOut "pre-scaleapply"
      new gg.xform.ScalesApply
        name: "scalesapply-#{@layerIdx}"
        params:
          posMapping: @geom.posMapping()
      @makeStdOut "post-scaleapply"
    ]

  compileGeomReparam: ->
    [
      @geom.reparam
      @makeStdOut "post-reparam"
    ]

  compileGeomPos: ->
    nodes = []
    if @pos.length > 0
      nodes = nodes.concat [
        @pos
        @makeStdOut "post-position"
      ]

    nodes = nodes.concat [
      @g.scales.pixel
      @makeStdOut "post-pixeltrain"

      #@g.facets.layout2
    ]
    nodes


  compileCoord: ->
    [
      @makeScalesOut "pre-coord"
      @coord
      @makeStdOut "post-coord"
    ]

  #
  # Rendering Nodes are all Client only
  #
  # render: render axes
  compileRender: ->
    [
      @g.renderNode
      @g.facets.render
      @g.facets.renderPanes()

      @makeStdOut "pre-render"
        location: "client"
      @geom.render
    ]




  compileNodes: (nodes) ->
    nodes = _.map _.compact(_.flatten nodes), (node) ->
      if node.compile?
        node.compile()
      else
        node
    _.compact _.flatten nodes





