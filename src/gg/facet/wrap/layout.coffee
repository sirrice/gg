#<< gg/facet/pane/container
#<< gg/facet/base/layout


# @deprecated for now
# XXX: whole mess of problems!!
#
class gg.facet.wrap.Layout extends gg.facet.base.Layout
  @ggpackage = "gg.facet.wrap.Layout"

  parseSpec: ->
    super

    @params.ensureAll
      ncol: [[], null]
      nrow: [[], null]


  # Computes the number of rows and columns so that
  # each facet is rendered close to a square
  # @param n number of distinct facets across all layers
  # @param container Bound object represents render container
  # @param params user and default parameters
  gridDimensions: (n, container, params) ->
    nxs = params.get "ncol"
    nys = params.get "nrow"
    [w,h] = [container.w(), container.h()]

    if nxs? and nys? and nxs*nys < n
      nys = null

    unless nxs? or nys?
      bestnxs = 1
      distance = Infinity
      for nxs in [1..n]
        nys = Math.ceil(n/nxs)
        d = Math.pow ((w / nxs) - (h / nys)), 2
        if d < distance
          bestnxs = nxs
          distance = d
      nxs = bestnxs
      nys = null
      @log "best nxs: #{nxs}"

    nxs = Math.ceil(n/nys) unless nxs?
    nys = Math.ceil(n/nxs) unless nys?
    @log "computing facet grid dimensions"
    @log "nxs/nys: #{nxs}/#{nys} of #{n} total panes"
    [nxs, nys]



  #
  # compute layout information for each pane in the grid view
  #
  layoutPanes: (datas, params, lc) ->
    # Setup Variables
    tables = _.map datas, (d) -> d.table
    envs = _.map datas, (d) -> d.env
    container = lc.plotC
    [w,h] = [container.w(), container.h()]
    paddingPane = params.get('paddingPane')
    showXAxis = params.get('showXAxis')
    showYAxis = params.get('showYAxis')
    xs = @xFacetVals datas
    ys = @yFacetVals datas
    xys = @facetVals datas

    @log "paddingPane, envs"
    @log paddingPane
    @log envs
    @log "container: #{w} x #{h}"

    # Compute derived values
    css = { 'font-size': '10pt' }
    dims = _.textSize @getMaxText(datas, 'y'), css
    yAxisW = dims.w + paddingPane
    labelHeight = _.exSize().h + paddingPane
    showXFacet = not(xs.length is 1 and not xs[0]?)
    showYFacet = not(ys.length is 1 and not ys[0]?)
    @log "yAxisW: #{yAxisW}"


    # compute the number of rows and columns needed to
    # render all of the facets
    [nxs, nys] = @gridDimensions xys.length, container, params
    grid = _.times nxs, () ->
      _.times nys, () -> null

    # every pane renders facet info, only y = nxs-1 renders xaxis
    xidx = 0
    yidx = 0
    for [x,y], idx in xys
      if xidx >= grid.length or xidx < 0
        @log.err xys
        @log.err grid
        throw Error "idx = #{idx}  xidx #{xidx} oob [0, #{grid.length}]"
      if yidx >= grid[xidx].length or yidx < 0
        @log.err xys
        @log.err grid
        throw Error "idx = #{idx}  yidx #{yidx} oob [0, #{grid[xidx].length}]"

      bXFacet = showXFacet
      bYFacet = showYFacet
      bXAxis = showXAxis and (idx >= xys.length-nxs)
      bYAxis = showYAxis and xidx is 0
      pane = new gg.facet.pane.Container(
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
      grid[xidx][yidx] = pane

      xidx += 1
      if xidx >= nxs
        xidx = 0
        yidx += 1

    [paneW, paneH] = @computePaneSizes grid, w, h, nxs, nys
    @log "pane size: #{paneW} x #{paneH}"
    @setPaneBounds grid, paneW, paneH
    @addPanesToEnv datas, grid, paddingPane


    # Compute optimal font sizes across the facets & add to envs
    xfonts = []
    yfonts = []
    for paneC in _.flatten(grid)
      continue unless paneC?
      [optX, optY] = @optimizeFontSize paneC
      xfonts.push optX
      yfonts.push optY

    optxfont = _.min(xfonts, (f) -> f.size)
    optyfont = _.min(yfonts, (f) -> f.size)
    optfont = _.min([optxfont, optyfont], (f) -> f.size)
    _.each xfonts, (f) -> f.size = optfont.size
    _.each yfonts, (f) -> f.size = optfont.size
    @log xfonts
    @log yfonts
    @setOptimalFacetFonts datas, grid, xfonts, yfonts





