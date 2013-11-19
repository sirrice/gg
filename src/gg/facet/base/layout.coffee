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
      options: [[], {}]



  facetVals: (md) ->
    Facets = gg.facet.base.Facets
    _.uniq(
      _.zip(md.all('facet-x'), md.all('facet-y')),
      false,
      JSON.stringify)


  # layout facets
  # layout panes
  getTitleHeight: (params) ->
    css = {}
    _.exSize(css).h# + params.get('paddingPane')

  getMaxYText: (md) -> @getMaxText md, 'y'
  getMaxYText: (md) -> @getMaxText md, 'y'


  getMaxText: (md, aes) ->
    text = '100'
    formatter = d3.format ',.0f'
    for set in md.all('scales')
      scale = set.scale aes, data.Schema.unknown
      if scale.type == data.Schema.numeric
        for v in scale.domain()
          if _.isNumber v
            _text = formatter v
          else
            _text = String v
          if _text? and _text.length > text.length
            text = _text
    text


  #
  # layout labels, background and container for the
  #
  # facet panes
  # Positions everything _relative_ to parent container
  #
  layoutLabels: (md, params, lc) ->
    options = params.get 'options'
    container = lc.facetC
    [w, h] = [container.w(), container.h()]
    Bound = gg.core.Bound

    xs = _.uniq md.all 'facet-x'
    ys = _.uniq md.all 'facet-y'
    nxs = xs.length
    nys = ys.length
    showXFacet = not(xs.length is 1 and not xs[0]?)
    showYFacet = not(ys.length is 1 and not ys[0]?)
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'
    paddingPane = params.get 'paddingPane'

    unless options.minimal
      titleH = @getTitleHeight(params)
      em = _.textSize("f", {padding: 3}).h
      @log "title size: #{titleH}"
      @log "em size: #{em}"

      plotW = w
      plotW -= (paddingPane + titleH) if showYAxis 
      plotW -= (paddingPane + titleH) if showYFacet
      plotH = h
      plotH -= (paddingPane + titleH) if showXAxis
      plotH -= (paddingPane + titleH) if showXFacet

      toffset = 0
      toffset += paddingPane + titleH if showXFacet
      yoffset = 0
      yoffset += paddingPane + titleH if showYAxis


      plotC = new Bound 0, 0, plotW, plotH
      plotC.d yoffset, toffset
      container = new gg.facet.pane.Container plotC,
        0,
        0,
        "",
        "",
        showXFacet,
        showYFacet,
        showXAxis,
        showYAxis,
        {
          labelHeight: em
          padding: 3
        }

      xFacetLabelC = container.xFacetC()
      xFacetLabelC.d (w-2*titleH)/2, 0

      yFacetLabelC = container.yFacetC()
      yFacetLabelC = new Bound yFacetLabelC.x0,
        (plotH/2 + (paddingPane+titleH)),
        yFacetLabelC.x0 + yFacetLabelC.w(),
        (plotH/2 + (paddingPane+titleH)) + yFacetLabelC.h()
      yFacetLabelC.d -em/2, 0

      xAxisLabelC = container.xAxisC()
      xAxisLabelC.d (w-2*titleH)/2, em/2

      yAxisLabelC = container.yAxisC()
      yAxisLabelC = new Bound yAxisLabelC.x0,
        (plotH/2 + (paddingPane+titleH)),
        yAxisLabelC.x0+yAxisLabelC.w(),
        (plotH/2 + (paddingPane+titleH)) + yAxisLabelC.h()
      @log "yAxisLabelC: #{yAxisLabelC.toString()}"

      xFacetlabelC = null unless showXFacet
      yFacetlabelC = null unless showYFacet
      xAxisLabelC = null unless showXAxis
      yAxisLabelC = null unless showYAxis

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

    md


  # compute actual pane sizes
  # constraints:
  # 1) label and axis heights are fixed (labelHeight)
  # 2) panes all have same height and width
  # 3) total height/width of panes + paddings + label + axes
  #    is equal to container.w()/h()
  computePaneSizes: (grid, w, h, nxs, nys) ->
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


  addPanesToEnv: (md, grid, paddingPane) ->
    # 1. add each pane's bounds to their environment
    # 2. update scale sets to be within drawing container
    md = md.project [
      {
        alias: 'paneC'
        f: (fx, fy) -> grid[fx][fy]
        type: data.Schema.object
        cols: ['facet-x', 'facet-y']
      }
    ], yes

    md.each (row) ->
      x = row.get 'facet-x'
      y = row.get 'facet-y'
      paneC = grid[x][y]
  
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

    set = md.any 'scales'
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
  setOptimalFacetFonts: (pairtable, grid, xfonts, yfonts) ->
    md = pairtable.right()
    partitions = md.partition ['facet-x', 'facet-y']
    partitions.each (row, idx) ->
      p = row.get 'table'
      x = row.get 'facet-x'
      y = row.get 'facet-y'
      xfont = xfonts[idx]
      yfont = yfonts[idx]
      p = p.setColVal "xfacet-text", xfont.text
      p = p.setColVal "xfacet-size", xfont.size
      p = p.setColVal "yfacet-text", yfont.text
      p = p.setColVal "yfacet-size", yfont.size
      p

  # augments layout container (lc) with additional
  # containers.
  #
  # Also augments md with paneC (pane container)
  compute: (pairtable, params) ->
    # Layout Containers: string -> Bound
    # will end up containing:
    #  background
    #  x and yFacetLabelC
    #  x and yaxisLabelC
    #  plotC
    #

    pairtable = pairtable.ensure ['facet-x', 'facet-y']
    md = pairtable.right()
    lc = md.any 'lc'

    md = @layoutLabels md, params, lc
    md = @layoutPanes md, params, lc

    pairtable.right md
    pairtable


