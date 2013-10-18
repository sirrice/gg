#<< gg/core/options
#<< gg/core/data
#<< gg/wf/*
#<< gg/data/*
#<< gg/facet/base/facet
#<< gg/layer/layers
#<< gg/scale/scales
#<< gg/stat/stat
#<< gg/geom/geom

try
  events = require 'events'
catch error
  console.log error

class gg.core.Graphic
  @ggpackage = "gg.core.Graphic"
  @envKeys = [
    'layer'
    'scales'
    'scalesconfig'
    'lc'
  ]


  constructor: (spec=null) ->
    @spec spec

  spec: (spec=null) ->
    unless spec?
      return @spec

    @spec = spec


    # setup debugging
    @debugspec = @spec.debug or { "": gg.util.Log.WARN }
    gg.util.Log.loggers = {}
    gg.util.Log.setDefaults @debugspec

    # extract specs
    @aesspec = _.findGoodAttr @spec, ["aes", "aesthetic", "mapping"], {}
    @layerspec = @spec.layers or []
    @facetspec = @spec.facets or @spec.facet or {}
    @scalespec = @spec.scales or {}
    @optspec = @spec.opts or @spec.opt or @spec.options or {}

    # The order to instantiate these objects matters
    @options = new gg.core.Options @optspec
    @facets = gg.facet.base.Facets.fromSpec @, @facetspec
    @layers = new gg.layer.Layers @, @layerspec
    @scales = new gg.scale.Scales @, @scalespec
    @datas = gg.core.Data.fromSpec @spec.data

    # connect layer specs with scales config
    _.each @layers.layers, (layer) =>
      @scales.scalesConfig.addLayerDefaults layer
      @datas.addLayerDefaults layer


    @svg = @options.svg or @svg

    @params = new gg.util.Params
      container: new gg.core.Bound 0, 0, @options.w, @options.h
      options: @options

    @eventCoordinator = new events.EventEmitter

    @log = gg.util.Log.logger @constructor.ggpackage, "core"


  pstore: ->
    if @workflow?
      gg.prov.PStore.get @workflow
    else
      @log.warn "plot has not been compiled.  no prov store found"
      null


  compile: ->
    @workflow = new gg.wf.Flow
    wf = @workflow

    # create shared nodes
    @layoutNode = new gg.core.Layout(
      name: 'core-layout'
      params: @params).compile()
    @renderNode = new gg.core.Render(
      name: 'core-render'
      params: @params).compile()


    #
    # pre-filter transformations??
    #

    preMulticastNodes = []
    preMulticastNodes.push @datas.data()
    preMulticastNodes.push @setupEnvNode()
    preMulticastNodes = _.compact preMulticastNodes

    prev = null
    for node in preMulticastNodes
      wf.node node
      wf.connectBridge prev, node if prev?
      prev = node


    # XXX: Only multicast to layers that use the default data
    # XXX: why does this need to be on the client? not clear
    #      multicast exports data clones to the same output port (facet)
    multicast = new gg.wf.Multicast
      params:
        location: "client"
    wf.node multicast
    wf.connectBridge prev, multicast if prev?

    _.each @layers.compile(), (nodes) ->
      prev = multicast
      for node in nodes
        wf.connect prev, node
        prev = node

      prev = multicast
      for node in nodes
        unless node.type == 'barrier'
          wf.connectBridge prev, node
          prev = node

    wf

  setupEnvNode: ->
    new gg.xform.EnvPut
      name: "graphic-setupenv"
      params:
        pairs:
          scalesconfig: @scales.scalesConfig
          svg:
            base: @svg
          event: @eventCoordinator
          options: @options
        location: 'client'

  renderGuides: -> null

  inputToTable: (input, cb) ->
    if _.isArray input
      table = gg.data.RowTable.fromArray input
      cb table
    else if _.isSubclass input, gg.data.Table
      table = input
      cb table
    else if _.isString input
      d3.csv input, (arr) ->
        table = gg.data.RowTable arr
        cb(table)


  render: (@svg, input) ->
    @log "running graphic.render"
    @log input
    $(@svg[0]).empty()
    @svg = @svg.append('svg')
    @compile()

    if input
      @log "prepending data node"
      @datas.setDefault input
      dataNode = @datas.data()
      @workflow.prepend dataNode

    if @options.optimize
      optimizer = new gg.wf.Optimizer [
        new gg.wf.rule.RPCify
      ]
      @workflow = optimizer.run @workflow

    @log "running workflow"
    #@workflow.on "done", () => parentSvg.append @svg
    @workflow.run @options



