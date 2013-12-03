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


  # layout facets
  # layout panes
  getTitleHeight: (params, css={}) -> _.exSize(css).h

  getMaxText: (sets, aes) ->
    text = '100'
    formatter = d3.format ',.0f'
    for set in sets
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
    Bound = gg.util.Bound

    [xs, ys] = md.all ['facet-x', 'facet-y']
    xs = _.uniq xs
    ys = _.uniq ys
    nxs = xs.length
    nys = ys.length
    showXFacet = not(xs.length is 1 and not xs[0]?)
    showYFacet = not(ys.length is 1 and not ys[0]?)
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'
    paddingPane = params.get 'paddingPane'

    unless options.minimal
      titleH = @getTitleHeight(params)
      em = _.textSize("fl", {padding: 3}).h
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
      plotC = new Bound 0, 0, w, h

    lc.background = container.clone()
    lc.xFacetLabelC = xFacetLabelC
    lc.yFacetLabelC = yFacetLabelC
    lc.xAxisLabelC = xAxisLabelC
    lc.yAxisLabelC = yAxisLabelC
    lc.plotC = plotC

    @log "background: #{container.toString()}"
    @log "plot area: #{plotC.toString()}"

    md


  # augments layout container (lc) with additional
  # containers.
  #
  # Also augments md with paneC (pane container)
  compute: (pairtable, params) ->
    pairtable = pairtable.ensure ['facet-x', 'facet-y']
    md = pairtable.right()
    lc = md.any 'lc'

    md = @layoutLabels md, params, lc
    md = @layoutPanes md, params, lc

    pairtable.right md
    pairtable


