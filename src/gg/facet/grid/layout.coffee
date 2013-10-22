#<< gg/facet/pane/container
#<< gg/facet/base/layout
#<< gg/facet/grid/pane



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
    paddingPane = params.get 'paddingPane'
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'
    log = @log

    #
    # Dimensions we are working with
    #
    container = lc.plotC
    [w,h] = [container.w(), container.h()]

    xs = _.uniq md.getColumn(xFacet)
    ys = _.uniq md.getColumn(yFacet)
    nxs = xs.length
    nys = ys.length

    # Compute derived values
    css = { 'font-size': '10pt' }
    labelHeight = _.exSize().h + paddingPane
    showXFacet = xs.length > 1 and xs[0]?
    showYFacet = ys.length > 1 and ys[0]?

    # axis label dimensions
    xdims = _.textSize @getMaxText(md, 'x'), css
    ydims = _.textSize @getMaxText(md, 'y'), css
    yAxisW = ydims.w + paddingPane
    xAxisW = xdims.w + paddingPane

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
        xAxisW
    }
    grid.layout w, h


    # make sure we have a MD row for every facet
    xytable = gg.data.Transform.cross 
      'facet-x': xs
      'facet-y': ys
    tmp = new gg.data.PairTable xytable, md
    tmp = tmp.ensure facetKeys
    md = tmp.getMD()

    xTextF = (text) -> {text:text, size: 8}
    yTextF = (text) -> {text:text, size: 8}
    ###
    xTextF = gg.util.Textsize.fitMany(
      xs, grid.paneW, labelHeight+paddingPane, 8, {padding: 2}
    )
    yTextF = gg.util.Textsize.fitMany(
      ys, grid.paneH, labelHeight+paddingPane, 8, {padding: 2}
    )
    ###

    # 
    # Update MD:
    # 1. add paneC 
    # 2. update x/y scale ranges
    # 3. update facet text opts
    #

    partitions = md.partition facetKeys
    partitions = _.map partitions, (p) ->
      x = p.get 0, xFacet
      y = p.get 0, yFacet
      paneC = grid.getByVal x, y
      drawC = paneC.drawC()

      # 1. add each pane's bounds to their environment
      p = p.setColumn 'paneC', paneC, gg.data.Schema.object
      p = p.setColumn 'xfacettext-opts', {text:x, size:8}
      p = p.setColumn 'yfacettext-opts', {text:y, size:8}

      # 2. update scale sets to be within drawing container
      xrange = [paddingPane, drawC.w()-2*paddingPane]
      yrange = [paddingPane, drawC.h()-2*paddingPane]
      for set in p.getColumn 'scales'
        for s in set.getAll gg.scale.Scale.xs
          s.range xrange
        for s in set.getAll gg.scale.Scale.ys
          s.range yrange

      xopts = xTextF x
      yopts = yTextF y
      p = p.setColumn 'xfacettext-opts', xopts
      p = p.setColumn 'yfacettext-opts', yopts
      p



    ###
    # Compute font sizes and add to md
    #
    _.map partitions, (p) ->



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
      xfont = xfonts[fkey[0]]
      yfont = yfonts[fkey[1]]
      p = p.setColumn 'xfacet-text', xfont.text
      p = p.setColumn 'xfacet-size', xfont.size
      p = p.setColumn 'yfacet-text', yfont.text
      p = p.setColumn 'yfacet-size', yfont.size
      p
    ###

    new gg.data.MultiTable null, partitions
