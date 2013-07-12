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


  # layout facets
  # layout panes
  getTitleHeight: (params) ->
    css = {}
    _.exSize(css).h# + params.get('paddingPane')

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




      ###
      # figure out top and left side containers
      # main labels
      xFacetLabelC = new gg.core.Bound titleH, paddingPane/2
      xFacetLabelC.d (w-2*titleH)/2, em

      # to compensate for rotation later
      yFacetLabelC = new gg.core.Bound titleH+(h-2*titleH)/2,
        -(w-titleH-paddingPane)

      xAxisLabelC = new gg.core.Bound titleH, h-titleH-paddingPane
      xAxisLabelC.d (w-2*titleH)/2, em

      # compensate for rotation later
      yAxisLabelC = new gg.core.Bound -(titleH+(h-2*titleH)/2),
        titleH
      yAxisLabelC = new gg.core.Bound titleH, (titleH+(h-2*titleH)/2)

      plotC = new gg.core.Bound titleH+paddingPane,
        titleH+paddingPane,
        w-2*(titleH-paddingPane)+titleH,
        h-2*(titleH-paddingPane)+titleH
      ###

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






