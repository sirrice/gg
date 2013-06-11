#<< gg/facet/pane/container
#<< gg/facet/base/layout


class gg.facet.grid.Layout extends gg.facet.base.Layout
  #
  # compute layout information for each pane in the grid view
  #
  layoutPanes: (tables, envs, params, lc) ->
    # Setup Variables
    log = @log
    container = lc.plotC
    [w,h] = [container.w(), container.h()]
    paddingPane = params.get('paddingPane') or 5
    showXAxis = params.get('showXAxis')
    showYAxis = params.get('showYAxis')
    xs = @xFacetVals tables, envs
    ys = @yFacetVals tables, envs
    nxs = xs.length
    nys = ys.length

    log envs
    log xs
    log ys

    # Compute derived values
    css = { 'font-size': '10pt' }
    dims = _.textSize @getMaxYText(envs), css
    yAxisW = dims.w
    labelHeight = _.exSize().h + 2*paddingPane
    showXFacet = not(xs.length is 1 and xs[0] is null)
    showYFacet = not(ys.length is 1 and ys[0] is null)

    # Initialize PaneContainers for each facet pane
    grid = _.map xs, (x, xidx) ->
      _.map ys, (y, yidx) ->
        bXFacet = showXFacet and yidx is 0
        bYFacet = showYFacet and xidx >= nxs-1
        bXAxis = showXAxis and yidx >= nys-1
        bYAxis = showYAxis and xidx is 0
        log "pane(#{xidx},#{yidx}): x/yfacet: #{bXFacet}, #{bYFacet}\tx/yaxis: #{bXAxis}, #{bYAxis}"
        new gg.facet.pane.Container gg.core.Bound.empty(),
          xidx,
          yidx,
          bXFacet,
          bYFacet,
          bXAxis,
          bYAxis,
          labelHeight,
          yAxisW

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
        dx = labelHeight*pane.bYFacet+yAxisW*pane.bYAxis
        dy = labelHeight*(pane.bXFacet+pane.bXAxis)
        nonPaneWs[yidx] += dx
        nonPaneHs[xidx] += dy

    # facet, axis width and height
    nonPaneW = _.mmax nonPaneWs
    nonPaneH = _.mmax nonPaneHs
    # total amount of width/height for panes
    paneH = (h - nonPaneH) / nys
    paneW = (w - nonPaneW) / nxs
    # add in padding to compute actual ranges
    xrange = [paddingPane, paneW-paddingPane]
    yrange = [paddingPane, paneH-paddingPane]

    # update all of the scales
    _.each envs, (env) ->
      scaleSet = gg.core.XForm.scales null, env

      _.each gg.scale.Scale.xs, (aes) ->
        _.each scaleSet.types(aes), (type) ->
          scaleSet.scale(aes, type).range xrange

      _.each gg.scale.Scale.ys, (aes) ->
        _.each scaleSet.types(aes), (type) ->
          scaleSet.scale(aes, type).range yrange

    # create bounds objects for each pane
    _.each grid, (paneCol, xidx) ->
      _.each paneCol, (pane, yidx) ->
        pane.c= new gg.core.Bound 0, 0, paneW, paneH
        dx = _.sum _.times xidx, (pxidx) -> grid[pxidx][yidx].w()
        dy = _.sum _.times yidx, (pyidx) -> grid[xidx][pyidx].h()
        pane.c.d dx, dy
        pane.c.d pane.yAxisC().w(), pane.xFacetC().h()

        log "pane(#{xs[xidx]},#{ys[yidx]}): #{pane.c.toString()}"
        #throw Error()



    # add each pane's bounds to their environment
    map = {}
    _.each xs, (x, xidx) ->
      _.each ys, (y, yidx) ->
        map[[x,y]] = grid[xidx][yidx]
        fenvs = gg.core.BForm.facetEnvs tables, envs, x, y
        _.each fenvs, (env) ->
          env.put 'paneC', grid[xidx][yidx]

    #lc.paneCs = grid
    #lc.paneMapping = map




  xy2paneId: (x, y, xs, ys) ->
    xidx = _.indexOf xs, x
    yidx = _.indexOf ys, y
    xidx + yidx * xs.length

  getMaxYText: (envs) ->
    scalesList = gg.core.BForm.scalesList null, envs
    text = "100"
    formatter = d3.format(",.0f")

    _.each scalesList, (scaleSet) ->
      yscale = scaleSet.scale 'y', gg.data.Schema.unknown
      y = yscale.maxDomain()
      if _.isNumber
        _text = formatter(y)
        text = _text if _text? and  _text.length > text.length

    return text



