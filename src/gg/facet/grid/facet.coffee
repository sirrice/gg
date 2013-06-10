#<< gg/facet/base/facet


class gg.facet.grid.Facets extends gg.facet.base.Facets
  constructor: ->
    super

    @layout1 = new gg.facet.grid.Layout @g,
      name: 'facet-layout1'
      params: @layoutParams
    @layout2 = new gg.facet.grid.Layout @g,
      name: 'facet-layout2'
      params: @layoutParams

  renderPanes: ->
    new gg.facet.pane.Svg


    # create the appropriate objects







  ###
  allocatePanes: (tables, envs, params) ->
    svg = params.get 'svg'


    # compute pixel size of largest y-axis value
    # used to compute y-axis label spacing
    formatter = d3.format(",.0f")
    maxValF = (s) ->
      yscale = s.scale 'y', gg.data.Schema.unknown
      y = yscale.maxDomain()
      y = 100 unless _.isNumber(y)
    maxVal = _.mmax _.compact _.map( @g.scales.scalesList, maxValF)
    dims = _.textSize(formatter(maxVal), {"font-size":"10pt", "font-family":"arial"})
    yAxisWidth = dims.w + 2*@facetPadding

    labelHeight = @exSize.h + 2*@facetPadding
    drawXFacet = not(@xs.length == 1 and @xs[0] is null)
    drawYFacet = not(@ys.length == 1 and @ys[0] is null)
    xFacetSize = if drawXFacet then labelHeight else 0
    yFacetSize = if drawYFacet then labelHeight else 0
    paneWidth = @w - yAxisWidth - yFacetSize
    paneHeight = @h - labelHeight - xFacetSize

    if @g.options.minimal
      paneWidth = @w
      paneHeight = @h
      xAxisWidth = yAxisWidth = yFacetSize = xFacetSize = labelHeight = 0

    yAxisOpts =
      left: 0
      top: labelHeight
      width: yAxisWidth
      height: @h - xFacetSize
      class: "y-axis axis"
    xAxisOpts =
      left: yAxisWidth
      top: @h - yFacetSize - labelHeight
      width: paneWidth
      height: labelHeight
      class: "x-axis axis"
    topFacetOpts =
      left: yAxisWidth
      top: 0
      width: paneWidth
      height: labelHeight
    rightFacetOpts =
      left: @w - labelHeight
      top: xFacetSize
      width: labelHeight
      height: paneHeight
    paneOpts =
      left: yAxisWidth
      top: xFacetSize
      width: paneWidth
      height: paneHeight
      class: "facet-grid-container"

    @log @xs
    @log @ys
    @xRange = d3.scale.ordinal().domain(@xs).rangeBands [0, paneWidth], 0.05, 0
    @yRange = d3.scale.ordinal().domain(@ys).rangeBands [0, paneHeight], 0.05, 0


    xRange = @xRange
    yRange = @yRange
    xBand = xRange.rangeBand()
    yBand = yRange.rangeBand()
    @log "xBand: #{xBand}\tyBand: #{yBand}\tpaneW: #{paneWidth}\tpaneH: #{paneHeight}"

    @setScalesRanges xBand, yBand

    @log topFacetOpts

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
    scale = scales.scale 'y', gg.data.Schema.unknown
    tickSize = xBand


    # this only works if type is numeric
    yAxis = d3.svg.axis()
      .scale(scales.scale('y',gg.data.Schema.unknown).d3())
      .orient('left')

    if scale.type == gg.data.Schema.numeric
      tickSize = 0 unless @showYTicks
      yAxis
        .ticks(5, d3.format(",.0f"), 5)
        .tickSize(-tickSize)

      # only show labels on the left-most facet pane
      yAxis.tickFormat('') unless x == @xs[0]

    svg.append('g')
       .attr('class', 'y axis')
       .attr('transform', "translate(#{left},#{top})")
       .call(yAxis)

    @log "rendered y-axis: #{scale.toString()}"

  renderXAxis: (svg, x, y, xRange, yRange) ->
    left = 0
    top = 0
    yBand = yRange.rangeBand()
    scales = @g.scales.facetScales x, y
    scale = scales.scale 'x', gg.data.Schema.unknown
    tickSize = yBand


    xAxis = d3.svg.axis()
        .scale(scale.d3())
        .orient('bottom')

    if scale.type == gg.data.Schema.numeric
      tickSize = 0 unless @showXTicks
      xAxis
        .ticks(5)
        .tickSize(- tickSize)

      # only render labels for bottom facet panes
      xAxis.tickFormat('') unless y == _.last(@ys)

    svg.append('g')
        .attr('class', 'x axis')
        .attr('fill', 'none')
        .attr('transform', "translate(0, #{yBand})")
        .call(xAxis)

    @log "rendered x-axis: #{scale.toString()}"

  renderTopLabels: (svg, xRange) ->
    return if @xs.length == 1 and @xs[0] is null

    labels = svg.selectAll("g").data(@xs)
    enter = labels.enter().insert("g").attr("class", "facet-label x")
    enter.append("rect")
    enter.append("text")

    labels.select("text").text((val) -> if val? then  String(val) else "")
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

  # Render y-axis Facet labels
  renderRightLabels: (svg, yRange) ->
    return if @ys.length == 1 and @ys[0] is null

    labels = svg.selectAll("g").data(@ys)
    enter = labels.enter().insert("g").attr("class", "facet-label y")
    enter.append("rect")
    enter.append("text")

    # XXX: allow customization function for the text
    labels.select("text").text (val) -> if val? then  String(val) else ""

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


  ###


