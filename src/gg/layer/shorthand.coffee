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
    #@setupStats()
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
    @stats = _.map @statSpec, (subSpec) ->
      gg.stat.Stat.fromSpec subSpec
    @stats

  setupPos: ->
    @posSpec  = @spec.pos
    @posSpec = _.flatten [@posSpec]
    @pos = _.map @posSpec, (subSpec) ->
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
    #nodes.push @compileStats()

    nodes.push @compileGeomMap()
    nodes.push new gg.xform.ScalesValidate
      name: 'scales-validate'
    nodes.push @compileInitialLayout()

    nodes.push @compileGeomReparam()
    nodes.push @compileGeomPos()
    nodes.push @compileCoord()
    nodes.push @compileRender()
    nodes.push gg.wf.SyncExec.create (pt) ->
      console.log pt.left().raw()
      pt

    nodes = @compileNodes nodes
    nodes



  compileSetup: ->
    [
      @makeEnvSetup()
      @map
      new gg.xform.ScalesSchema
        name: "scales-schema-#{@layerIdx}"
        params:
          config: @g.scales.scalesConfig
      @g.facets.labeler
    ]

  compileStats: ->

    [
      # train & filter scales
      @makeStdOut "pre-train"
      @g.scales.prestats
      @makeScalesOut "pre-stat-#{@layerIdx}"
      @makeStdOut "post-train"

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

      @g.facets.layout2
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





