




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
class gg.Facets
  constructor: (@g, @spec={}) ->
    @parseSpec()

    @splitter = @splitterNodes()

    @panes = []
    # paneSvgMapper[x val][y val] -> svg for the pane
    @paneSvgMapper = {}
    @xAxisSvgMapper = {}
    @yAxisSvgMapper = {}
    @axesSvgMapper = {}



  parseSpec: ->
    @x = findGood [@spec.x, () -> 1]
    @y = findGood [@spec.y, () -> 1]
    @scales = findGood [@spec.scales, "fixed"]
    @type = findGood [@spec.type, "grid"]
    @sizing = findGood [@spec.sizing, @spec.size, "fixed"]
    @facetXKey = "facetX"
    @facetYKey = "facetY"

    # rendering options
    @margin = findGood [@spec.margin, 10]
    @facetXLabel = findGoodAttr @spec, ['xlabel', 'xLabel', null]
    @facetYLabel = findGoodAttr @spec, ['ylabel', 'yLabel', null]
    @facetFontSize = findGood [@spec.fontSize, @spec['font-size'], "12pt"]
    @facetFontFamily = findGood [@spec.fontFamily, @spec['font-family'],  "arial"]
    @facetPadding = findGood [@spec.facetPadding, 5]
    @panePadding = findGood [@spec.panePadding, 10]
    @exSize = _.exSize
      "font-size": @facetFontSize
      "font-family": @facetFontFamily



  # Accessor for facet pane objects
  svgPane: (facetX, facetY) ->
    try
      @paneSvgMapper[facetX][facetY]
    catch error
      throw error


  # Create the appropriate workflow split/partition node given the facet's
  # x/y specification
  #
  # @param facet is the facet-X or facet-Y specification
  # @param the name of the facet's grouping column
  createSplitterNode: (facet, name) ->
      if _.isString facet
          new gg.wf.Partition {f: ((row) -> row.get(facet)), name: name}
      else if _.isFunction facet
          new gg.wf.Partition {f: facet, name: name}
      else if _.isArray(facet) and facet.length > 0
          if _.isString facet[0]
              colnames = facet
              f = (table) =>
                  # create a new table. creates a new column called {name}
                  # and populated with column in colnames
                  _.map colnames, (colname) ->
                      newtable = table.clone()
                      newtable.addColumn name, table.getColumn(colname)
                      {key: colname, table: newtable}
              new gg.wf.Split {f: f, name: name}
          else:
              throw Error("Faceting by transformations not implemented yet")
      # TODO: also support varying run-time parameters


  splitterNodes: ->
    # XXX: This implementation is not exactly right, because it will not result
    #      in groups for x/y facetpairs that don't have any tuples.
    #      (we expect the cross product!)
    console.log "splitternode: #{@facetXKey},  #{@facetYKey}"
    facetXNode = @createSplitterNode @x, @facetXKey
    facetYNode = @createSplitterNode @y, @facetYKey
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
    @xs = {}
    @ys = {}
    _.each tables, (table) =>
      if table.nrows() > 0
        @xs[table.get(0, @facetXKey)] = yes
        @ys[table.get(0, @facetYKey)] = yes

    @xs = _.uniq _.keys(@xs)
    @ys = _.uniq _.keys(@ys)

    # sort x and y.
    # TODO: support custom ordering
    @xs.sort()
    @ys.sort()

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

  #
  # layout labels, background and container for the facet panes
  #
  layoutFacets: (tables, envs, node) ->
    w = @g.wFacet
    h = @g.hFacet
    svgFacet = @g.svgFacet

    # add a plot background
    _.subSvg svgFacet, {
      class: "plot-background"
      width: w
      height: h
    }, "rect"


    facetTitleSize = "13pt"
    titleDims = _.exSize
      "font-size": facetTitleSize
      "font-family": "arial"
    hTitle = titleDims.h + @facetPadding
    # XXX: make showing facet titles and axes configurable


    svgFacet.append("g").append("text")
      .text(@facetXLabel or @x)
      .attr("transform", "translate(#{hTitle}, #{@facetPadding/2})")
      .attr("dy", "1em")
      .attr("dx", (w-2*hTitle) / 2)
      .attr("text-anchor", "middle")
      .attr("class", "facet-title")
      .style("font-size", facetTitleSize)
      .style("font-family", "arial")

    svgFacet.append("g").append("text")
      .text(@facetYLabel or @y)
      .attr("transform", "rotate(90)translate(#{hTitle+(h-2*hTitle)/2},-#{w-hTitle-@facetPadding})")
      .attr("text-anchor", "middle")
      .attr("class", "facet-title")
      .style("font-size", facetTitleSize)
      .style("fon-family", "arial")

    # XXX: have better API to retrieve axis labels!
    svgFacet.append("text")
      .text("xaxis")
      .attr("transform", "translate(#{hTitle}, #{h-hTitle-@facetPadding})")
      .attr("dx", (w-2*hTitle)/2)
      .attr("text-anchor", "middle")
    svgFacet.append("text")
      .text("yaxis")
      .attr("transform", "rotate(-90)translate(#{-(hTitle+(h-2*hTitle)/2)},#{hTitle})")
      .attr("text-anchor", "middle")




    pDims =
      left: hTitle
      top: hTitle
      width: w - 2*(hTitle-@facetPadding)
      height: h - 2*(hTitle-@facetPadding)
      wRatio: (w-2*(hTitle-@facetPadding)) / w
      hRatio: (h-2*(hTitle-@facetPadding)) / h

    matrix = "#{pDims.wRatio},0,0,#{pDims.hRatio},#{pDims.left},#{pDims.top}"

    @w = pDims.width
    @h = pDims.height
    @svg = svgFacet.append('g')
      .attr("class", "graphic-with-margin")
      .attr("transform", "matrix(#{matrix})")






  # allocate SVG objects for all the facet's graphic components
  allocatePanes: (tables, envs, node) ->
    #margin = @margin / 2
    #matrix = "#{1.0-2*margin/@w},0,0,
    #          #{1.0-2*margin/@h},
    #          #{margin}, #{margin}"
    #svg = @svg.append('g')
    #    .attr('class', 'graphic-with-margin')
    #    .attr('transform', "matrix(#{matrix})")

    svg = @svg


    # compute dimensions for each container
    # top facet space
    console.log "exSize: #{JSON.stringify @exSize}"

    # compute pixel size of largest y-axis value
    # used to compute y-axis label spacing
    formatter = d3.format(",.0f")
    maxValF = (s) ->
      100
      #if _.isNumber s.scale('y').maxDomain()
      #  s.scale('y').maxDomain()
      #else
      #  0
    maxVal = _.max(_.map @g.scales.scalesList, maxValF)
    dims = _.textSize(formatter(maxVal), {"font-size":"10pt", "font-family":"arial"})
    yAxisWidth = dims.w + 2*@facetPadding

    facetSize = @exSize.h + 2*@facetPadding
    paneWidth = @w - yAxisWidth - facetSize
    paneHeight = @h - 2 * facetSize
    yAxisOpts =
      left: 0
      top: facetSize
      width: yAxisWidth#  facetSize
      height: @h - facetSize
      class: "y-axis axis"
    xAxisOpts =
      left: yAxisWidth# facetSize
      top: @h - facetSize
      width: paneWidth#@w - facetSize
      height: facetSize
      class: "x-axis axis"
    topFacetOpts =
      left: yAxisWidth# facetSize
      top: 0
      width: paneWidth
      height: facetSize
    rightFacetOpts =
      left: @w - facetSize
      top: facetSize
      width: facetSize
      height: paneHeight
    paneOpts =
      left: yAxisWidth#facetSize
      top: facetSize
      width: paneWidth
      height: paneHeight
      class: "facet-grid-container"

    console.log @xs
    console.log @ys
    @xRange = d3.scale.ordinal().domain(@xs).rangeBands [0, paneWidth], 0.05, 0
    @yRange = d3.scale.ordinal().domain(@ys).rangeBands [0, paneHeight], 0.05, 0
    xRange = @xRange
    yRange = @yRange
    xBand = xRange.rangeBand()
    yBand = yRange.rangeBand()
    console.log "x/yBand: #{xBand} / #{yBand}\t#{paneWidth} / #{paneHeight}"

    @setScalesRanges xBand, yBand

    console.log topFacetOpts

    #
    # create and populate svgs for the facet labels
    #
    svgL = _.subSvg svg, {class: "labels-container"}
    svgTopLabels = _.subSvg svgL, topFacetOpts
    @renderTopLabels svgTopLabels, xRange
    svgRightLabels = _.subSvg svgL, rightFacetOpts
    @renderRightLabels svgRightLabels, yRange





    #
    # create svg elements for each pane, and add them to the map
    #
    svgPanes = _.subSvg svg, paneOpts


    _.each @xs, (x, xidx) =>
      _.each @ys, (y, yidx) =>
        left = xRange x
        top = yRange y

        # create the pane
        svgPane = _.subSvg svgPanes, {
          width: xBand
          height: yBand
          left: left
          top: top
          id: "facet-grid-#{xidx}-#{yidx}"
          class: "facet-grid"
        }

        svgBg = svgPane.append('g')
        _.subSvg svgBg, {
          width: xBand
          height: yBand
          class: "facet-grid-background"
        }, "rect"

        # save the pane
        @paneSvgMapper[x] = {} unless x of @paneSvgMapper
        @paneSvgMapper[x][y] = svgPane

        # save the background axes containers
        @axesSvgMapper[x] = {} unless x of @axesSvgMapper
        @axesSvgMapper[x][y] = svgBg


  renderAxes: (tables, envs, nodes) ->
    _.each @xs, (x, xidx) =>
      _.each @ys, (y, yidx) =>
        # render the axes!
        svgBg = @axesSvgMapper[x][y]
        @renderYAxis svgBg, x, y, @xRange, @yRange
        @renderXAxis svgBg, x, y, @xRange, @yRange


  renderYAxis: (svg, x, y, xRange, yRange) ->
    left = 0#xRange x
    top = 0#yRange y
    xBand = xRange.rangeBand()
    scales = @g.scales.facetScales x, y
    scale = scales.scale 'y', gg.Schema.unknown

    console.log "gg.Facet.renderYAxis, scaleid #{scale.id}\t#{scale.toString()}"
    yAxis = d3.svg.axis()
      .scale(scales.scale('y',gg.Schema.unknown).d3())
      .ticks(5, d3.format(",.0f"), 5)
      .tickSize(-xBand)
      .orient('left')

    yAxis.tickFormat('') unless x == @xs[0]

    svg.append('g')
       .attr('class', 'y axis')
       .attr('transform', "translate(#{left},#{top})")
       .call(yAxis)

  renderXAxis: (svg, x, y, xRange, yRange) ->
    left = 0
    top = 0
    yBand = yRange.rangeBand()
    scales = @g.scales.facetScales x, y

    xAxis = d3.svg.axis()
        .scale(scales.scale('x',gg.Schema.unknown).d3())
        .ticks(5)
        .tickSize(- yBand)
        .orient('bottom')

    xAxis.tickFormat('') unless y == _.last(@ys)

    svg.append('g')
        .attr('class', 'x axis')
        .attr('fill', 'none')
        .attr('transform', "translate(0, #{yBand})")
        .call(xAxis)


  renderTopLabels: (svg, xRange) ->
    labels = svg.selectAll("g").data(@xs)
    enter = labels.enter().insert("g").attr("class", "facet-label x")
    enter.append("rect")
    enter.append("text")

    labels.select("text").text(String)
    enter.select("text")
      .attr("x", (d) -> xRange(d) + xRange.rangeBand()/2)
      .attr("y", @facetPadding)
      .attr("dy", "1em")
      .style("font-size", @facetFontSize)
      .style("font-family", @facetFontFamily)
    enter.select("rect")
      .attr("x", xRange)
      .attr("y", 0)
      .attr("width", xRange.rangeBand())
      .attr("height", svg.attr("height"))

  renderRightLabels: (svg, yRange) ->
    labels = svg.selectAll("g").data(@ys)
    enter = labels.enter().insert("g").attr("class", "facet-label y")
    enter.append("rect")
    enter.append("text")

    labels.select("text").text(String)
    enter.select("text")
      .attr("dx", ".5em")
      .attr("y", (d) -> yRange(d) + yRange.rangeBand()/2)
      .attr("rotate", 90)
      .style("font-size", @facetFontSize)
      .style("font-family", @facetFontFamily)
    enter.select("rect")
      .attr("x", 0)
      .attr("y", yRange)
      .attr("width", svg.attr("width"))
      .attr("height", yRange.rangeBand())








  ###########################
  #
  # Scales related Methods
  #
  ###########################

  expandDomains: (scalesSet) ->
    # XXX: this should be done in the scales/scalesSet object!!!


  # train fixed scales (every pane has the same x,y domains)
  trainScales: ->
    console.log "gg.Facet.trainScales: number of scales: #{@g.scales.scalesList.length}"
    console.log "gg.Facet.trainScales: first scales: #{@g.scales.scalesList[0].clone().toString()}" if @g.scales.scalesList.length > 0

    @masterScales = gg.ScalesSet.merge @g.scales.scalesList
    @expandDomains @masterScales

    str = @masterScales.toString()
    console.log "gg.Facet.trainScales: master scales #{str}"

    if @scales is "fixed"
      _.each @g.scales.scalesList, (scalesSet) =>
        scalesSet.merge @masterScales, false
    else
      @trainFreeScales()



  trainFreeScales: ->
    # now compute the shared scales for each column and row
    @xScales = _.map @xs, (x) =>
        gg.ScalesSet.merge(_.map @ys, (y) => @subFacets[x][y].scales)
            .exclude(gg.Scale.ys)

    @yScales = _.map @ys, (y) =>
        gg.ScalesSet.merge(_.map @xs, (x) => @subFacets[x][y].scales)
           .exclude(gg.Scale.xs)


    # TODO: expand their domains -- or this should be a separate operation?
    #

    # expand each layer's scalesSet's domains
    _.each @xs, (x, xidx) =>
      _.each @ys, (y, yidx) =>
        layerScalesSets = @g.scales.scales(x, y)
        _.each layerScalesSets, (ss) =>
          ss.merge @xScales[xidx], no
          ss.merge @yScales[yidx], no




  setScalesRanges: (xBand, yBand) ->
    range = [0+@panePadding, xBand-@panePadding]
    console.log "facet.setScalesRanges range: #{range}"
    _.each @g.scales.scalesList, (ss) =>
      _.each gg.Scale.xs, (aes) =>
        _.each ss.types(aes), (type) =>
          #ss.scale(aes, type).range [0, xBand]
          ss.scale(aes, type).range range
          console.log "facet.setScalesRanges(#{aes},#{type}):\t#{ss.scale(aes, type).toString()}"

      _.each gg.Scale.ys, (aes) =>
        _.each ss.types(aes), (type) =>
          #ss.scale(aes, type).range [yBand-@panePadding, 0+@panePadding]
          ss.scale(aes, type).range [0+@panePadding, yBand-@panePadding]
          #ss.scale(aes, type).range [0, yBand]
        #console.log "facet.setScalesRanges(#{aes}):\t#{ss.scale(aes).toString()}"






  # render the panes
  renderPanesFunc: (tables, envs, barrier) ->

  renderPanes: -> new gg.wf.Barrier (args...) => @renderPanesFunc(args...)



