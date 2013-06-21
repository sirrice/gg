#<< gg/core/options
#<< gg/wf/*
#<< gg/data/*
#<< gg/facet/base/facet
#<< gg/layer/layers
#<< gg/scale/scales
#<< gg/stat/stat
#<< gg/geom/geom

class gg.core.Graphic
  @envKeys = [
    'layer'
    'scales'
    'scalesconfig'
    'lc'
  ]


  constructor: (@spec={}) ->
    @aesspec = _.findGoodAttr @spec, ["aes", "aesthetic", "mapping"], {}
    @layerspec = @spec.layers or []
    @facetspec = @spec.facets or @spec.facet or {}
    @scalespec = @spec.scales or {}
    @optspec = @spec.opts or @spec.options or {}

    # The order to instantiate these objects matters
    @options = new gg.core.Options @optspec
    @facets = gg.facet.base.Facets.fromSpec @, @facetspec
    @layers = new gg.layer.Layers @, @layerspec
    @scales = new gg.scale.Scales @, @scalespec

    # connect layer specs with scales config
    _.each @layers.layers, (layer) =>
      @scales.scalesConfig.addLayerDefaults layer


    @svg = @options.svg or @svg

    @params = new gg.util.Params
      container: new gg.core.Bound 0, 0, @options.w, @options.h
      options: @options

    @layoutNode = new gg.core.Layout(
      name: 'core-layout'
      params: @params).compile()
    @renderNode = new gg.core.Render(
      name: 'core-render'
      params: @params).compile()



  # XXX: graphic object responsible for
  #
  #   1. getting scales
  #   2. getting svg containers (+ width/height layout constraints)


  compile: ->
    @workflow = new gg.wf.Flow {g: @}
    wf = @workflow

    #
    # pre-filter transformations??
    #

    preMulticastNodes = []
    preMulticastNodes.push @setupEnvNode()
    preMulticastNodes = preMulticastNodes.concat @facets.splitter

    prev = null
    for node in preMulticastNodes
      wf.node node
      wf.connectBridge prev, node if prev?
      wf.connect prev, node if prev?
      prev = node


    multicast = new gg.wf.Multicast
      params:
        clientonly: yes
    wf.node multicast
    wf.connectBridge prev, multicast if prev?
    wf.connect prev, multicast if prev?

    _.each @layers.compile(), (nodes) ->
      prev = multicast
      for node in nodes
        wf.connect prev, node
        prev = node

      prev = multicast
      for node in nodes
        unless _.isSubclass node, gg.wf.Barrier
          wf.connectBridge prev, node
          prev = node

    wf

  setupEnvNode: ->
    new gg.wf.EnvPut
      name: "graphic-setupenv"
      params:
        pairs:
          scalesconfig: @scales.scalesConfig
          svg:
            base: @svg
          options: @options
        clientonly: yes

  renderGuides: -> null

  inputToTable: (input, cb) ->
    if _.isArray input
      table = gg.data.RowTable.fromArray input
    else if _.isSubclass input, gg.data.Table
      table = input
    else if _.isString input
      null
    cb table


  render: (@svg, input) ->
    @inputToTable input, (table) =>
      $(svg[0]).empty()
      @svg = @svg.append('svg')
      @compile()

      optimizer = new gg.wf.Optimizer
      @workflow = optimizer.optimize @workflow
      @workflow.run table



