#<< gg/util/*
#<< gg/core/options
#<< gg/core/data
#<< gg/wf/*
#<< gg/facet/base/facet
#<< gg/layer/layers
#<< gg/scale/scales
#<< gg/stat/stat
#<< gg/geom/geom

try
  events = require 'events'
catch error
  console.log error

###
layer: (idx) ->
  if idx?
    addorcreate idx
  else
    add null

geom:

stat:

pos:

aes:

data: 

facets:

debug: (str, v) ->

opt: (keyOrMap, val)




class gg.core.layer

  geom: () ->
    get or est

  stat: () ->

  pos

  facets

###


class gg.core.Graphic extends events.EventEmitter
  @ggpackage = "gg.core.Graphic"
  @envKeys = [
    'layer'
    'scales'
    'scalesconfig'
    'lc'
  ]


  constructor: (spec=null) ->
    spec = gg.parse.Parser.parse spec
    @spec spec

  spec: (spec) ->
    unless spec?
      return @spec

    @spec = spec


    # setup debugging
    gg.util.Log.reset()
    gg.util.Log.setDefaults @spec.debug

    # The order to instantiate these objects matters
    @options = new gg.core.Options @spec.options
    @facets = gg.facet.base.Facets.fromSpec @, @spec.facets
    @layers = new gg.layer.Layers @, @spec.layers
    @scales = new gg.scale.Scales @
    @datas = gg.core.Data.fromSpec @spec.data


    # connect layer specs with scales config
    _.each @layers.layers, (layer) =>
      @scales.scalesConfig.addLayer layer
      @datas.addLayer layer

    @svg = @options.svg or @svg

    @params = new gg.util.Params
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

    preMulticastNodes = []
    #preMulticastNodes.push @datas.data()
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
        unless node.isBarrier()
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

  optimize: ->
    rules = [
      new gg.wf.rule.RPCify
    ]

    for name in @options.optimize
      rules.push gg.wf.rule.Rule.fromSpec name
    rules = _.compact rules
    optimizer = new gg.wf.Optimizer rules
    @workflow = optimizer.run @workflow


  render: (svg, input) ->
    @log "running graphic.render"
    @log input

    @svg = svg if svg?
    $(@svg[0]).empty()
    @svg = @svg.append('svg')


    @compile()

    if input
      @log "prepending data node"
      @datas.setDefault input
      dataNode = @datas.data()
      @workflow.prepend dataNode

    @optimize()

    @workflow.on "output", (nodeid, port, data) =>
      @emit "output", nodeid, port, data
    @workflow.on "done", (debug) => 
      @emit "done", debug

    @log "running workflow"
    @workflow.run @options



