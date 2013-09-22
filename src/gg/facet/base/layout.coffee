#<< gg/core/bform

# Computes bounding boxes for
# 1) facet major labels (groupby attribute labels)
# 2) facet minor labels (groupby values)
# 3) x and y axis bounding boxes
# 4) map: facet -> bounding boxes
#
# Adds this information to the environment
#
#
# Need the following data
# 1) Container bounding box
# 2) yaxis label (to make proper spacing)
# 3) number of x facets
# 4) number of y facets
# 5) if axes will be shown
# 6) padding information
#    - between panes
#    - around axis labels
#
class gg.facet.base.Layout extends gg.core.BForm
  @ggpackage = "gg.facet.base.Layout"

  parseSpec: ->
    super

    @params.ensureAll
      showXAxis: [[], yes]
      showYAxis: [[], yes]
      paddingPane: [[], 5]
      margin: [[], 1]


  xFacetVals: (datas) ->
    @pick datas, gg.facet.base.Facets.facetXKey

  yFacetVals: (datas) ->
    @pick datas, gg.facet.base.Facets.facetYKey

  facetVals: (datas) ->
    Facets = gg.facet.base.Facets
    xys = {}
    for data in datas
      pair = [data.env.get(Facets.facetXKey), data.env.get(Facets.facetYKey)]
      key = JSON.stringify pair
      xys[key] = pair
    xys = _.values xys
    @log "xys: #{JSON.stringify xys}"
    xys


  # layout facets
  # layout panes
  getTitleHeight: (params) ->
    css = {}
    _.exSize(css).h# + params.get('paddingPane')

  getMaxYText: (datas) ->
    envs = _.map datas, (d) -> d.env
    scalesList = gg.core.FormUtil.scalesList datas
    text = "100"
    formatter = d3.format(",.0f")

    _.each scalesList, (scaleSet) ->
      yscale = scaleSet.scale 'y', gg.data.Schema.unknown
      y = yscale.maxDomain()
      if _.isNumber
        _text = formatter(y)
        text = _text if _text? and  _text.length > text.length

    return text




  #
  # layout labels, background and container for the
  #
  # facet panes
  # Positions everything _relative_ to parent container
  #
  layoutLabels: (datas, params, lc) ->
    tables = _.map datas, (d) -> d.table
    envs = _.map datas, (d) -> d.env
    options = params.get 'options'
    container = lc.facetC
    [w, h] = [container.w(), container.h()]
    Bound = gg.core.Bound

    xs = @xFacetVals datas
    ys = @yFacetVals datas
    nxs = xs.length
    nys = ys.length
    showXFacet = not(xs.length is 1 and not xs[0]?)
    showYFacet = not(ys.length is 1 and not ys[0]?)


    paddingPane = params.get 'paddingPane'

    unless options.minimal
      titleH = @getTitleHeight(params)
      em = _.textSize("m", {}).h
      @log.warn "title size: #{titleH}"
      @log.warn "em size: #{em}"

      plotW = w
      plotW -= (paddingPane + titleH) # yaxis
      plotW -= (paddingPane + titleH) if showYFacet
      plotH = h
      plotH -= (paddingPane + titleH) # xaxis
      plotH -= (paddingPane + titleH) if showXFacet

      toffset = 0
      toffset += paddingPane + titleH if showXFacet

      plotC = new Bound 0, 0, plotW, plotH
      plotC.d (paddingPane+titleH), toffset
      container = new gg.facet.pane.Container plotC,
        0,
        0,
        "",
        "",
        showXFacet,
        showYFacet,
        true,
        true,
        em,
        em,
        0

      xFacetLabelC = container.xFacetC()
      xFacetLabelC.d (w-2*titleH)/2, 0

      yFacetLabelC = container.yFacetC()
      yFacetLabelC = new Bound yFacetLabelC.x0,
        (plotH/2 + (paddingPane+titleH)),
        yFacetLabelC.x0 + yFacetLabelC.w(),
        (plotH/2 + (paddingPane+titleH)) + yFacetLabelC.h()
      yFacetLabelC.d -em/2, 0

      xAxisLabelC = container.xAxisC()
      xAxisLabelC.d (w-2*titleH)/2, em

      yAxisLabelC = container.yAxisC()
      yAxisLabelC = new Bound yAxisLabelC.x0,
        (plotH/2 + (paddingPane+titleH)),
        yAxisLabelC.x0+yAxisLabelC.w(),
        (plotH/2 + (paddingPane+titleH)) + yAxisLabelC.h()
      @log "yAxisLabelC: #{yAxisLabelC.toString()}"

      plotC = container.drawC()
    else
      xFacetLabelC = null
      yFacetLabelC = null
      xAxisLabelC = null
      yAxisLabelC = null
      plotC = new gg.core.Bound 0, 0, w, h

    lc.background = container.clone()
    lc.xFacetLabelC = xFacetLabelC
    lc.yFacetLabelC = yFacetLabelC
    lc.xAxisLabelC = xAxisLabelC
    lc.yAxisLabelC = yAxisLabelC
    lc.plotC = plotC

    @log "background: #{container.toString()}"
    @log "plot area: #{plotC.toString()}"


  computePaneSizes: (grid, w, h, nxs, nys) ->

    # compute actual pane sizes
    # constraints:
    # 1) label and axis heights are fixed (labelHeight)
    # 2) panes all have same height and width
    # 3) total height/width of panes + paddings + label + axes
    #    is equal to container.w()/h()

    # compute available w/h space for panes
    nonPaneWs = _.times nys, ()->0
    nonPaneHs = _.times nxs, ()->0
    _.each grid, (paneCol, xidx) ->
      _.each paneCol, (pane, yidx) ->
        return unless pane?
        dx = pane.labelHeight*pane.bYFacet+pane.yAxisW*pane.bYAxis
        dy = pane.labelHeight*(pane.bXFacet+pane.bXAxis)
        nonPaneWs[yidx] += dx
        nonPaneHs[xidx] += dy

    # facet, axis width and height
    nonPaneW = _.mmax nonPaneWs
    nonPaneH = _.mmax nonPaneHs
    # total amount of width/height for panes
    paneW = (w - nonPaneW) / nxs
    paneH = (h - nonPaneH) / nys

    [paneW, paneH]

  setPaneBounds: (grid, paneW, paneH) ->
    # create bounds objects for each pane
    @log "creating bounds objects for each pane"
    _.each grid, (paneCol, xidx) =>
      _.each paneCol, (pane, yidx) =>
        return unless pane?
        c = pane.c
        pane.c.x1 = paneW
        pane.c.y1 = paneH
        dx = _.sum _.times xidx, (pxidx) -> grid[pxidx][yidx].w()
        dy = _.sum _.times yidx, (pyidx) -> grid[xidx][pyidx].h()
        @log "pane at #{pane.xidx}x#{pane.yidx} has dx,dy #{dx}, #{dy}"
        @log "pane(#{pane.x},#{pane.y}) before: #{c.w()} x #{c.h()}"
        pane.c.d dx, dy
        c = pane.drawC()
        @log "pane(#{pane.x},#{pane.y}) after: #{c.w()} x #{c.h()}"
        @log pane
        pane.c.d pane.yAxisC().w(), pane.xFacetC().h()


  addPanesToEnv: (datas, grid, paddingPane) ->
    # 1. add each pane's bounds to their environment
    # 2. update scale sets to be within drawing container
    for paneC in _.flatten(grid)
      continue unless paneC?
      [x, y] = [paneC.x, paneC.y]

      fdatas = gg.core.FormUtil.facetDatas datas, x, y
      for fdata in fdatas
        env = fdata.env
        env.put 'paneC', paneC

        # add in padding to compute actual ranges
        drawC = paneC.drawC()
        xrange = [paddingPane, drawC.w()-2*paddingPane]
        yrange = [paddingPane, drawC.h()-2*paddingPane]

        # update the scales
        scaleSet = gg.core.FormUtil.scales fdata
        for aes in gg.scale.Scale.xs
          for type in scaleSet.types(aes)
            scaleSet.scale(aes, type).range xrange

        for aes in gg.scale.Scale.ys
          for type in scaleSet.types(aes)
            scaleSet.scale(aes, type).range yrange

    set = _.first gg.core.FormUtil.scalesList datas
    @log "grid layout scale set"
    @log set.toString()

  
  optimizeFontSize: (paneC) ->
    return unless paneC?
    [x, y] = [paneC.x, paneC.y]
    xText = String x
    yText = String y
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()

    optXFont = gg.util.Textsize.fit xText, xfc.w(), xfc.h(), 8, {padding: 2}
    optYFont = gg.util.Textsize.fit yText, yfc.h(), yfc.w(), 8, {padding: 2}
    [optXFont, optYFont]

  # @param xfonts font object for each non-null grid item
  setOptimalFacetFonts: (datas, grid, xfonts, yfonts) ->
    ixd = 0
    for paneC, idx in _.compact _.flatten(grid)
      [x, y] = [paneC.x, paneC.y]
      xfont = xfonts[idx]
      yfont = yfonts[idx]

      fenvs = gg.core.FormUtil.facetEnvs datas, x, y
      for env in fenvs
        env.put "xfacet-text", xfont.text
        env.put "xfacet-size", xfont.size
        env.put "yfacet-text", yfont.text
        env.put "yfacet-size", yfont.size
      idx += 1











  # augments layout container (lc) with additional
  # containers.
  #
  # Also augments envs with paneC (pane container)
  compute: (datas, params) ->
    # Layout Containers: string -> Bound
    # will end up containing:
    #  background
    #  x and yFacetLabelC
    #  x and yaxisLabelC
    #  plotC
    #
    lc = _.first(datas).env.get 'lc'
    tables = _.map datas, (data) -> data.table
    envs = _.map datas, (data) -> data.env

    @layoutLabels datas, params, lc
    @layoutPanes datas, params, lc

    _.each envs, (env) -> env.put 'lc', lc
    datas






