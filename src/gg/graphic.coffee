#<< gg/wf/*
#<< gg/facet
#<< gg/layer
#<< gg/scale
#<< gg/stat
#<< gg/geom

class gg.Graphic
    constructor: (@spec) ->
      @layerspec = findGood [@spec.layers, []]
      @facetspec = findGood [@spec.facets, {}]
      @scalespec = findGood [@spec.scales, {}]
      @options = findGood [@spec.opts, @spec.options, {}]

      @layers = new gg.Layers @, @layerspec
      @facets = new gg.Facets @, @facetspec
      @scales = new gg.Scales @, @scalespec


    svgPane: (facetX, facetY, layer) ->
      @facets.svgPane(facetX, facetY, layer)

    # XXX: graphic object responsible for
    #
    #   1. getting scales
    #   2. getting svg containers (+ width/height layout constraints)


    compile: ->
      wf = @workflow = new gg.wf.Flow {
          g: @
      }

      #
      # pre-filter transformations??
      #

      _.each @facets.splitter, (node) ->
        wf.node node

      multicast = new gg.wf.Multicast
      wf.node multicast
      _.each @layers.compile(), (nodes) ->
          prev = multicast
          _.each nodes, (node) ->
              wf.connect prev, node
              prev = node

      wf

    renderGuides: -> null

    # Barrier that renders guides, title, margins, layout, etc
    layoutNode: ->
      f = (tables, envs, node) =>
        @svg = @svg.append("svg")
          .attr("width", @w)
          .attr("height", @h)
        @svg.append("rect")
          .attr("class", "graphic-background")
          .attr("width", "100%")
          .attr("height", "100%")

        hTitle = 40

        @wFacet = @w
        @hFacet = @h - hTitle
        @svgFacet = @svg.append("g")
          .attr("transform", "translate(0, #{hTitle})")
          .attr("width", @wFacet)
          .attr("height", @hFacet)
        @renderGuides()

        # title sits on the top, so draw it last
        svgTitle = @svg.append("g")
          .append("text")
            .text("Title of Graph")
            .attr("class", "graphic-title")
            .attr("style", "font-size: 30px")
            .attr("dy", "1em")

        tables
      new gg.wf.Barrier
        name: "layoutNode"
        f: f



    # XXX: at what point do we render the title/guides etc?
    render: (@w, @h, @svg, table) ->
      if _.isArray table
        table = new gg.RowTable table

      @compile()
      @workflow.run table


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
        layer = new gg.Layer @g, spec

      layer.layerIdx = layerIdx
      @layers.push layer

#
# This scales object manages the mapping throughout the workflow between
#
#   [facetX, facetY, layerIdx] -> trained scales object
#
# It provides the following access methods
#
#   @scales(facetX, facetY, layerIdx) --> scales
#   @scales() --> scales
#
#
# A Scale defines an invertable mapping from a Domain -> Range.
#
# Scales transform, train and map at multiple places in workflow
#
#   transform: apply scale transformation
#   untransform: apply inverse of scale transformation
#   train: learn the domains of all tables in the workflow
#   map: remove oob values, round to 500'th decimal, compute palettes, etc
#
#
# In each case, the scales _only_ train on known and supported aesthetic
# attributes that can be found in the tables
#
# !!! This means that any aesthetic mappings need to be applied before the
# barrier node that performs the training !!!
#
# Users can specify pre-statistics and post-statistics aesthetic mappings.
# By default, if users only specify one mapping, it's assumed to be pre-statistics mapping
#
# Pre-statistics: these are defined by preStats + postStats, just blindly apply
#
# Post-statistics: sometimes, the statistics will compute auxiliary attributes that the
# user wants to plot (e.g., SUM, AVG, Q1).  Rather than using the x,y
# attributes from pre-stats, the user can explicitly change the attributes to
# be used for rendering geometries.
#
class gg.Scales extends gg.XForm
  @UNTRAINED = 0
  @PREGEOM = 1
  @PRERENDER = 2
  @POSTRENDER = 3
  @POSTFACET = 4


  constructor: (@g, @spec) ->
    @scalesFactory = null
    @mapping = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects
    @state = gg.Scales.UNTRAINED

    @parseSpec()

    @prestatsNode = new gg.wf.Barrier
      name: "scales:prestats"
      f: (args...) => @trainOnData(args..., gg.Scales.PREGEOM)

    @pregeomNode = new gg.wf.Barrier
      name: "scales:poststats"
      f: (args...) => @trainOnData(args..., gg.Scales.PRERENDER)

    @prerenderNode = new gg.wf.Barrier
      name: "scales:postgeom"
      f: (args...) => @trainOnPixels(args..., gg.Scales.POSTRENDER)

    @facetNode = new gg.wf.Barrier
      name: "scales:facet"
      f: (args...) => @trainForFacets(args..., gg.Scales.POSTFACET)

  parseSpec: ->
    # setup the scales factory
    @scalesFactory = new gg.ScaleFactory @spec


  setMapping: (mappings, info, scales) ->
    facetX = info.facetX
    facetY = info.facetY
    layerIdx = info.layer

    mappings[facetX] = {} unless facetX of mappings
    xmappings = mappings[facetX]
    xmappings[facetY] = {} unless facetY of xmappings
    ymappings = xmappings[facetY]
    ymappings[layerIdx] = scales

  # these training methods assume that the tables's attribute names have
  # been mapped to the aesthetic attributes that the scales expect
  trainOnData: (tables, envs, node, nextState=null) ->

    mappings = {}
    scalesList = []
    _.each _.zip(tables, envs), ([t,e]) =>
      info = @paneInfo t, e
      aess = @aesthetics info.layer
      console.log "train scale aess: #{aess}"

      scales = @scalesFactory.scales aess
      scales.train t, aess
      scalesList.push scales
      @setMapping mappings, info, scales

    @mappings = mappings
    @scalesList = scalesList
    @state = nextState if nextState?
    @g.facets.trainScales()
    tables


  # Train on a table that has been mapped to aesthetic domain.
  #
  # Need to invert the aesthetic columns to be in the value domain before training
  #
  trainOnPixels: (tables, envs, node, nextState=null) ->
    mappings = {}
    scalesList = []
    _.each _.zip(tables, envs), ([table,e]) =>
      t = table.clone()
      info = @paneInfo t, e
      aess = @aesthetics info.layer

      scales = @scalesFactory.scales aess
      inverted = scales.invert t, aess
      scales.train inverted, aess
      scalesList.push scales
      @setMapping mappings, info, scales
      console.log "pixeltrained scales: #{scales.scale('x').domain()}"

    @mappings = mappings
    @scalesList = scalesList
    @state = nextState if nextState?
    @g.facets.trainScales()
    tables

  trainForFacets: (tables, envs, node, nextState) ->
    unless @state is gg.Scales.POSTRENDER
      throw Error("gg.Scales.trainForFacets: state (#{@state}) != POSTRENDER")
    @g.facets.trainScales()
    @state = nextState


  layer: (layerIdx) -> @g.layers.getLayer layerIdx

  # XXX: layer aesthetics should differentiate between pre-post stats aesthetic mappings!
  aesthetics: (layerIdx) ->
    scalesAess = _.keys(@scalesFactory.paneDefaults)
    layerAess =  @layer(layerIdx).aesthetics()
    aess = _.compact _.uniq _.flatten([scalesAess, layerAess, ['y', 'x']])
    aess

  facetScales: (facetX, facetY) ->
    try
      mapping = @mappings[facetX][facetY]
      gg.ScalesSet.merge _.values(mapping)
    catch error
      throw Error("gg.ScalesfacetScales: could not find scales\n\t#{error}")

  scales: (facetX=null, facetY=null, layerIdx=null) ->
    try
      if layerIdx?
        @mappings[facetX][facetY][layerIdx]
      else
        _.values @mappings[facetX][facetY]
    catch error
      throw Error("gg.Scales.scales: could not find scales\n\t#{error}")



