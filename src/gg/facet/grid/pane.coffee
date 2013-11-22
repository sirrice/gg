
#
# Encapsulates the panes in a grid layout
#
# Each pane needs to keep track of its x/y scales and x/y facets
#
class gg.facet.grid.PaneGrid
  constructor: (@xs, @ys, opts) ->
    showXFacet = opts.showXFacet
    showYFacet = opts.showYFacet
    showXAxis = opts.showXAxis
    showYAxis = opts.showYAxis
    labelHeight = opts.labelHeight
    yAxisW = opts.yAxisW
    xAxisW = opts.xAxisW
    padding = opts.padding
    nxs = @xs.length
    nys = @ys.length

    opts = {
      labelHeight
      yAxisW
      xAxisW
      padding
    }

    @grid = _.map @xs, (x, xidx) =>
      _.map @ys, (y, yidx) =>
        bXFacet = showXFacet and yidx is 0
        bYFacet = showYFacet and xidx >= nxs-1
        bXAxis = showXAxis and yidx >= nys-1
        bYAxis = showYAxis and xidx is 0
        new gg.facet.pane.Container(
          gg.util.Bound.empty(),
          xidx,
          yidx,
          x,
          y,
          bXFacet,
          bYFacet,
          bXAxis,
          bYAxis,
          opts
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
    ret = _.map @grid, (o, xidx) =>
      _.map o, (pane, yidx) =>
        f pane, xidx, yidx, @xs[xidx], @ys[yidx]
    _.flatten ret


  # compute actual pane sizes
  # constraints:
  # 1) label and axis heights are fixed (labelHeight)
  # 2) panes all have same height and width
  # 3) total height/width of panes + paddings + label + axes
  #    is equal to container.w()/h()
  layout: (w, h) ->
    #
    # compute offset given the space for the pane's facets/axes 
    #
    nonPaneWs = _.times @ys.length, ()->0
    nonPaneHs = _.times @xs.length, ()->0
    @each (pane, xidx, yidx, x, y) ->
      dx = pane.labelHeight * pane.bYFacet + pane.yAxisW * pane.bYAxis
      dy = pane.labelHeight * (pane.bXFacet + pane.bXAxis)
      nonPaneWs[yidx] += dx
      nonPaneHs[xidx] += dy

    #
    # compute amount of w/h for each pane's content
    #
    nonPaneW = _.mmax nonPaneWs
    nonPaneH = _.mmax nonPaneHs
    @paneH = paneH = (h - nonPaneH) / @ys.length
    @paneW = paneW = (w - nonPaneW) / @xs.length


    @each (pane, xidx, yidx, x, y) =>
      pane.c.x1 = paneW
      pane.c.y1 = paneH
      dx = _.sum _.map @xPrefix(xidx, yidx), (pane) -> pane.w()
      dy = _.sum _.map @yPrefix(xidx, yidx), (pane) -> pane.h()
      pane.c.d dx, dy
      pane.c.d pane.yAxisC().w(), pane.xFacetC().h()



