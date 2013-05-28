
#
# Processing:
# 1) Splits dataset to be processed for different facets
#
# Rendering
# 1) Allocates svg elements for each facet pane and
# 2) Provides API to access them
#
# XXX: in the future, this should be an abstract class that computes
#      offset and sizes of containers, and subclasses should use them
#      to create appropriate SVG/Canvas elements
#
#
# Spec:
#
#   facets: {
#     (x|y): ???
#     type: grid|wrap,
#     scales: free|fixed,
#     (size|sizing): free|fixed
#   }
#
class gg.facet.Facets
  constructor: (@g, @spec={}) ->
    @log = gg.util.Log.logger "Facets", gg.util.Log.DEBUG

    @parseSpec()

    @splitter = @splitterNodes()
    @trainer = @trainerNode()

    @panes = []
    # paneSvgMapper[x val][y val] -> svg for the pane
    @paneSvgMapper = {}
    @xAxisSvgMapper = {}
    @yAxisSvgMapper = {}
    @axesSvgMapper = {}



  parseSpec: ->
    @x = _.findGood [@spec.x, () -> null]
    @y = _.findGood [@spec.y, () -> null]
    @scales = _.findGood [@spec.scales, "fixed"]
    @type = _.findGood [@spec.type, "grid"]
    @sizing = _.findGood [@spec.sizing, @spec.size, "fixed"]
    @facetXKey = "facetX"
    @facetYKey = "facetY"

    # rendering options
    @margin = _.findGood [@spec.margin, 10]
    @facetXLabel = _.findGoodAttr @spec, ['xlabel', 'xLabel', null]
    @facetYLabel = _.findGoodAttr @spec, ['ylabel', 'yLabel', null]
    @facetFontSize = _.findGood [@spec.fontSize, @spec['font-size'], "12pt"]
    @facetFontFamily = _.findGood [@spec.fontFamily, @spec['font-family'],  "arial"]
    @facetPadding = _.findGood [@spec.facetPadding, 5]
    @panePadding = _.findGood [@spec.panePadding, 10]
    @exSize = _.exSize
      "font-size": @facetFontSize
      "font-family": @facetFontFamily

    @showXTicks = _.findGood [@spec.showXTicks, true]
    @showYTicks = _.findGood [@spec.showYTicks, true]

    @log "spec: #{JSON.stringify @spec}"

  @fromSpec: (g, spec) ->
    spec.type = spec.type or "grid"

    klass = if spec.type is "wrap"
      gg.facet.Wrap
    else
      gg.facet.Grid

    new klass g, spec



  # Accessor for facet pane objects
  svgPane: (facetX, facetY) ->
    try
      @paneSvgMapper[facetX][facetY]
    catch error
      throw error


  # Create the appropriate workflow split/partition node
  # given the facet's x/y specification
  #
  # @param facet is the facet-X or facet-Y specification
  # @param the name of the facet's grouping column
  createSplitterNode: (name, facetSpec) ->
    gg.xform.Split.createNode name, facetSpec

  # Return workflow nodes that split the dataset along the x and y facets
  splitterNodes: ->
    # XXX: This implementation is not exactly right, because it
    # will not result in groups for x/y facetpairs that don't have
    # any tuples.  this should only be apparent when using "wrap"
    # (we expect the cross product!)
    @log "splitternode: #{@facetXKey}: #{@x},  #{@facetYKey}: #{@y}"
    facetXNode = @createSplitterNode @facetXKey, @x
    facetYNode = @createSplitterNode @facetYKey, @y
    [facetXNode, facetYNode]

  labelerNodes: ->
    xyjoin = new gg.wf.Barrier
      name: "facetxy-join"
      f: (ts,es,n) =>
        newts = _.map ts, (t) =>
          t = t.clone()
          t.addConstColumn @facetXKey, e.group(@facetXKey, "1")
          t.addConstColumn @facetYKey, e.group(@facetYKey, "1")
          t
        newts

    xjoin = new gg.wf.Exec
      name: "facetx-join"
      f: (t,e,n) =>
        t = t.clone()
        t.addConstColumn @facetXKey, e.group(@facetXKey, "1")
        t
    yjoin = new gg.wf.Exec
      name: "facety-join"
      f: (t,e,n) =>
        t = t.clone()
        t.addConstColumn @facetYKey, e.group(@facetYKey, "1")
        t
    [xjoin, yjoin]

  #########################
  #
  # Allocate containers and determine sizes for each pane
  # 1) compute dimensions given margins
  # 2) compute dimensions of the facet labels.  Instantiate them
  # 3) compute dimensions for each pane.  Instantiate them
  # 4) update the range of each pane's position scales
  #
  #########################

  collectXYs: (tables, envs, node) ->
    # compute x and y group values
    @xs = []
    @ys = []
    _.each tables, (table) =>
      if table.nrows() > 0
        x = table.get 0, @facetXKey
        y = table.get 0, @facetYKey
        @xs.push x
        @ys.push y

    @xs = _.uniq @xs
    @ys = _.uniq @ys

    # sort x and y.
    # TODO: support custom ordering
    @xs.sort()
    @ys.sort()

  reallocatePanesNode: ->
    unless @_reallocatePanesNode?
      @_reallocatePanesNode = new gg.wf.Barrier {
        f: (tables, envs, node) =>
          @allocatePanes(tables, envs, node)
          tables
      }
    @_reallocatePanesNode

  allocatePanesNode: ->
    unless @_allocatePanesNode?
      @_allocatePanesNode = new gg.wf.Barrier {
        f: (tables, envs, node) =>
          @collectXYs(tables, envs, node)
          @layoutFacets(tables, envs, node)
          @allocatePanes(tables, envs, node)
          tables
      }
    @_allocatePanesNode

  renderAxesNode: ->
    unless @_renderAxesNode?
      @_renderAxesNode = new gg.wf.Barrier {
        f: (tables, envs, nodes) =>
          @renderAxes tables, envs, nodes
          tables
      }
    @_renderAxesNode



  layoutFacets: (tables, envs, node) ->
    throw Error("gg.Facet.layoutFacets not implemented")


  # allocate SVG objects for all the facet's graphic components
  allocatePanes: (tables, envs, node) ->
    throw Error("gg.Facet.allocatePanes not implemented")


  renderAxes: (tables, envs, nodes) ->
    throw Error("gg.Facet.renderAxes not implemented")
  renderYAxis: (svg, x, y, xRange, yRange) ->
    throw Error("gg.Facet.renderYAxis not implemented")
  renderXAxis: (svg, x, y, xRange, yRange) ->
    throw Error("gg.Facet.renderXAxis not implemented")
  renderTopLabels: (svg, xRange) ->
    throw Error("gg.Facet.renderTopLabels not implemented")
  renderRightLabels: (svg, yRange) ->
    throw Error("gg.Facet.renderRightLabels not implemented")



  ###########################
  #
  # Scales related Methods
  #
  ###########################

  trainerNode: ->
    new gg.wf.Barrier
      name: "facet-train"
      f: (tables, envs, node) =>
        @trainScales()
        tables



  expandDomains: (scalesSet) ->
    return scalesSet

    _.each scalesSet.scalesList(), (scale) =>
      return unless scale.type is gg.data.Schema.numeric

      [mind, maxd] = scale.domain()
      extra = if mind == maxd then 1 else Math.abs(maxd-mind) * 0.05
      mind = mind - extra
      maxd = maxd + extra
      @log "expandDomain: #{scale.aes}: #{scale.domain()} to [#{mind}, #{maxd}"
      scale.domain [mind, maxd]

    # XXX: this should be done in the scales/scalesSet object!!!


  # train fixed scales (every pane has the same x,y domains)
  # XXX: This should be idempotent!  It is not because of
  #      expandDomains()
  trainScales: ->
    @trainMasterScales()

    if @scales is "fixed"
      _.each @g.scales.scalesList, (scalesSet) =>
        scalesSet.merge @masterScales, true#false
    else
      @trainFreeScales()

  trainMasterScales: ->
    @log "trainScales: # scales: #{@g.scales.scalesList.length}"

    @masterScales = gg.scale.Set.merge @g.scales.scalesList
    @expandDomains @masterScales

    str = @masterScales.toString()
    @log "trainScales: master scales #{str}"
    @masterScales



  trainFreeScales: ->
    # now compute the shared scales for each column and row
    @xScales = _.map @xs, (x) =>
        gg.scale.Set.merge(_.map @ys, (y) => @subFacets[x][y].scales)
            .exclude(gg.scale.Scale.ys)

    @yScales = _.map @ys, (y) =>
        gg.scale.Set.merge(_.map @xs, (x) => @subFacets[x][y].scales)
           .exclude(gg.scale.Scale.xs)

    # Expand domains
    _.each @xScales, (set) => @expandDomains set
    _.each @yScales, (set) => @expandDomains set


    # expand each layer's scalesSet's domains
    _.each @xs, (x, xidx) =>
      _.each @ys, (y, yidx) =>
        layerScalesSets = @g.scales.scales(x, y)
        _.each layerScalesSets, (ss) =>
          ss.merge @xScales[xidx], no
          ss.merge @yScales[yidx], no




  setScalesRanges: (xBand, yBand) ->
    range = [0+@panePadding, xBand-@panePadding]
    @log "setScalesRanges range: #{range}"

    _.each @g.scales.scalesList, (ss) =>
      _.each gg.scale.Scale.xs, (aes) =>
        _.each ss.types(aes), (type) =>
          #ss.scale(aes, type).range [0, xBand]
          ss.scale(aes, type).range range
          @log "setScalesRanges(#{aes},#{type}):\t#{ss.scale(aes, type).toString()}"

      _.each gg.scale.Scale.ys, (aes) =>
        _.each ss.types(aes), (type) =>
          #ss.scale(aes, type).range [yBand-@panePadding, 0+@panePadding]
          ss.scale(aes, type).range [0+@panePadding, yBand-@panePadding]
          #ss.scale(aes, type).range [0, yBand]
          @log "setScalesRanges(#{aes},#{type}):\t#{ss.scale(aes, type).toString()}"


