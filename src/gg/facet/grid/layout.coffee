#<< gg/facet/pane/container
#<< gg/facet/base/layout



class gg.facet.grid.PaneGrid
  constructor: (@xs, @ys, opts) ->
    showXFacet = opts.showXFacet
    showYFacet = opts.showYFacet
    showXAxis = opts.showXAxis
    showYAxis = opts.showYAxis
    labelHeight = opts.labelHeight
    yAxisW = opts.yAxisW
    nxs = @xs.length
    nys = @ys.length

    @grid = _.map @xs, (x, xidx) =>
      _.map @ys, (y, yidx) =>
        bXFacet = showXFacet and yidx is 0
        bYFacet = showYFacet and xidx >= nxs-1
        bXAxis = showXAxis and yidx >= nys-1
        bYAxis = showYAxis and xidx is 0
        new gg.facet.pane.Container(
          gg.core.Bound.empty(),
          xidx,
          yidx,
          x,
          y,
          bXFacet,
          bYFacet,
          bXAxis,
          bYAxis,
          labelHeight,
          yAxisW
        )

  getByIdx: (xidx, yidx) -> @grid[xidx][yidx]

  getByVal: (x, y) ->
    xidx = _.indexOf @xs, x
    yidx = _.indexOf @ys, y
    @getByIdx xidx, yidx

  xPrefix: (xidx, yidx) ->
    _.times xidx, (i) => @grid[i][yidx]

  yPrefix: (xidx, yidx) ->
    _.times yidx, (i) => @grid[xidx][i]




  each: (f) ->
    ret = _.map @grid, (o, x) ->
      _.map o, (pane, y) ->
        f pane, x, y
    _.flatten ret


class gg.facet.grid.Layout extends gg.facet.base.Layout
  @ggpackage = "gg.facet.grid.Layout"


  #
  # compute layout information for each pane in the grid view
  #
  layoutPanes: (md, params, lc) ->
    xFacet = 'facet-x'
    yFacet = 'facet-y'
    facetKeys = [xFacet, yFacet]

    # Setup Variables
    log = @log
    container = lc.plotC
    [w,h] = [container.w(), container.h()]
    paddingPane = params.get 'paddingPane'
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'

    xs = _.uniq md.getColumn(xFacet)
    ys = _.uniq md.getColumn(yFacet)
    nxs = xs.length
    nys = ys.length

    # Compute derived values
    css = { 'font-size': '10pt' }
    dims = _.textSize @getMaxYText(md), css
    yAxisW = dims.w + paddingPane
    labelHeight = _.exSize().h + paddingPane
    showXFacet = xs.length > 1 and xs[0]?
    showYFacet = ys.length > 1 and ys[0]?

    log "paddingPane, md, xs, ys:"
    log paddingPane
    log md.raw()
    log xs
    log ys

    grid = new gg.facet.grid.PaneGrid xs, ys, {
        showXFacet
        showYFacet
        showXAxis
        showYAxis
        labelHeight
        yAxisW 
    }

    nonPaneWs = _.times nys, ()->0
    nonPaneHs = _.times nxs, ()->0
    grid.each (pane, xidx, yidx) ->
      x = xs[xidx]
      y = ys[yidx]
      dx = labelHeight*pane.bYFacet+yAxisW*pane.bYAxis
      dy = labelHeight*(pane.bXFacet+pane.bXAxis)
      nonPaneWs[yidx] += dx
      nonPaneHs[xidx] += dy

    
    # compute actual pane sizes
    # constraints:
    # 1) label and axis heights are fixed (labelHeight)
    # 2) panes all have same height and width
    # 3) total height/width of panes + paddings + label + axes
    #    is equal to container.w()/h()

    # facet, axis width and height
    nonPaneW = _.mmax nonPaneWs
    nonPaneH = _.mmax nonPaneHs
    # total amount of width/height for panes
    paneH = (h - nonPaneH) / nys
    paneW = (w - nonPaneW) / nxs

    grid.each (pane, xidx, yidx) ->
      pane.c.x1 = paneW
      pane.c.y1 = paneH
      dx = _.sum _.map grid.xPrefix(xidx, yidx), (pane) -> pane.w()
      dy = _.sum _.map grid.yPrefix(xidx, yidx), (pane) -> pane.h()
      pane.c.d dx, dy
      pane.c.d pane.yAxisC().w(), pane.xFacetC().h()

      log "pane(#{xs[xidx]},#{ys[yidx]}): #{pane.c.toString()}"

    # create bounds objects for each pane
    log "creating bounds objects for each pane"

    # 1. add each pane's bounds to their environment
    # 2. update scale sets to be within drawing container

    xytable = gg.data.Transform.cross 
      'facet-x': xs
      'facet-y': ys
    tmp = new gg.data.PairTable xytable, md
    tmp = tmp.ensure [xFacet, yFacet]
    md = tmp.getMD()
    partitions = md.partition facetKeys
    partitions = _.map partitions, (p) ->
      fkey = _.map facetKeys, (fk) -> p.get 0, fk
      paneC = grid.getByVal fkey[0], fkey[1]
      drawC = paneC.drawC()
      xrange = [paddingPane, drawC.w()-2*paddingPane]
      yrange = [paddingPane, drawC.h()-2*paddingPane]


      p = gg.data.Transform.mapCols p,
        paneC: () -> paneC
        scales: (scales) ->
          for aes in gg.scale.Scale.xs
            for type in scales.types(aes)
              scales.scale(aes, type).range xrange
          for aes in gg.scale.Scale.ys
            for type in scales.types(aes)
              scales.scale(aes, type).range yrange
          scales
      p



    #
    # Compute font sizes and add to md
    #
    fit = (args...) -> gg.util.Textsize.fit args...
    xfonts = {}
    yfonts = {}

    for x, xidx in xs
      text = String x
      paneC = grid.getByIdx xidx, 0
      xfc = paneC.xFacetC()
      optfont = fit text, xfc.w(), xfc.h(), 8, {padding: 2}
      xfonts[x] = optfont
      @log "optfont x #{text}: #{JSON.stringify optfont}"

    for y, yidx in ys
      text = String y
      paneC = grid.getByIdx nxs-1, yidx
      yfc = paneC.yFacetC()
      optfont = fit text, yfc.h(), yfc.w(), 8, {padding: 2}
      yfonts[y] = optfont
      @log "optfont y #{text}: #{JSON.stringify optfont}"

    xminsize = _.min(xfonts, (f) -> f.size).size
    yminsize = _.min(yfonts, (f) -> f.size).size
    _.each xfonts, (f) -> f.size = xminsize
    _.each yfonts, (f) -> f.size = yminsize

    partitions = _.map partitions, (p) ->
      fkey = _.map facetKeys, (fk) -> p.get 0, fk
      paneC = grid.getByVal fkey[0], fkey[1]
      xfont = xfonts[x]
      yfont = yfonts[y]

      gg.data.Transform.transform p,
        'xfacet-text': () -> xfont.text
        'xfacet-size': () -> xfont.size
        'yfacet-text': () -> yfont.text
        'yfacet-size': () -> yfont.size

    new gg.data.MultiTable null, partitions
