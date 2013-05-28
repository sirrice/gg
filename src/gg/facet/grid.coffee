#<< gg/facet/facet


class gg.facet.Grid extends gg.facet.Facets


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
      .text(@g.options.xaxis)
      .attr("transform", "translate(#{hTitle}, #{h-hTitle-@facetPadding})")
      .attr("dx", (w-2*hTitle)/2)
      .attr("text-anchor", "middle")
    svgFacet.append("text")
      .text(@g.options.yaxis)
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





  allocatePanes: (tables, envs, node) ->
    svg = @svg


    # compute dimensions for each container
    # top facet space
    @log "exSize: #{JSON.stringify @exSize}"

    # compute pixel size of largest y-axis value
    # used to compute y-axis label spacing
    formatter = d3.format(",.0f")
    maxValF = (s) ->
      yscale = s.scale 'y', gg.data.Schema.unknown
      if _.isNumber yscale.maxDomain()
        yscale.maxDomain()
      else
        100
    maxVal = _.mmax(_.map @g.scales.scalesList, maxValF)
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





