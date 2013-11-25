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

    #
    # Setup Variables
    #
    paddingPane = params.get 'paddingPane'
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'
    log = @log

    # Dimensions we are working with
    container = lc.plotC
    [w,h] = [container.w(), container.h()]

    # x/y facet values
    xs = _.uniq md.all(xFacet)
    ys = _.uniq md.all(yFacet)
    nxs = xs.length
    nys = ys.length
    xytable = data.ops.Util.cross
      'facet-x': xs
      'facet-y': ys

    # Compute derived values
    css = { 'font-size': '10pt' }  ## isn't there a facet class somewhere?
    labelHeight = _.exSize().h 
    showXFacet = xs.length > 1 and xs[0]?
    showYFacet = ys.length > 1 and ys[0]?

    # axis label dimensions
    xdims = _.textSize @getMaxText(md, 'x'), css
    ydims = _.textSize @getMaxText(md, 'y'), css
    yAxisW = ydims.w + paddingPane
    xAxisW = xdims.w + paddingPane

    log "paddingpane: #{paddingPane}"
    log "facetxs:     #{xs}"
    log "facetys:     #{ys}"
    log "labelHeight: #{labelHeight}"

    #
    # OK layout time
    #

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


    #
    # make sure we have a MD row for every facet
    #
    tmp = new data.PairTable xytable, md
    tmp = tmp.ensure facetKeys
    md = tmp.right()

    # 
    # Update MD:
    # 1. add paneC 
    # 2. update x/y scale ranges
    # 3. update facet text opts
    #

    mapping = [{
      alias: ['paneC', 'xfacettext-opts', 'yfacettext-opts']
      cols: [xFacet, yFacet, 'scales']
      f: (x, y, set) ->
        paneC = grid.getByVal x, y
        drawC = paneC.drawC()

        if set?
          xrange = [paddingPane, drawC.w()-2*paddingPane]
          yrange = [paddingPane, drawC.h()-2*paddingPane]
          xscales = _.compact _.uniq _.map gg.scale.Scale.xs, (col) -> set.get col
          yscales = _.compact _.uniq _.map gg.scale.Scale.ys, (col) -> set.get col
          for s in xscales
            s.range xrange
          for s in yscales
            s.range yrange
        else
          console.log "[W] facet #{x}, #{y} has no scaleset"

        xopts = { text: x, size: 8 }
        yopts = { text: y, size: 8 }

        xfc = paneC.xFacetC()
        yfc = paneC.yFacetC()
        xTextF = gg.util.Textsize.fitMany(
          xs, xfc.w(), xfc.h(), 8, {padding: 2}
        )
        yTextF = gg.util.Textsize.fitMany(
          ys, yfc.w(), labelHeight, 8, {padding: 2}
        )
        xopts = xTextF x
        yopts = yTextF y

        {
          'paneC': paneC
          'xfacettext-opts': xopts
          'yfacettext-opts': yopts
        }
    }]
    md = md.project mapping, yes
    md
