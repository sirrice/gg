#<< gg/core/xform

class gg.facet.pane.Svg extends gg.core.XForm
  @ggpackage = "gg.facet.pane.Svg"

  parseSpec: ->
    super
    @params.put "location", "client"

  # Create SVG elements for all facets, axes, and panes
  # Does not render the geometries, simply allocates them
  compute: (table, env, params) ->
    svg = env.get('svg').plot
    b2translate = (b) -> "translate(#{b.x0},#{b.y0})"
    paneC = env.get 'paneC'
    return table unless paneC?

    info = @paneInfo table, env, params
    layerIdx = info.layer
    scaleSet = @scales table, env, params
    dc = paneC.drawC()
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()
    xac = paneC.xAxisC()
    yac = paneC.yAxisC()
    em = _.textSize("m", {padding: 2})

    @log "panec: #{paneC.toString()}"
    @log "bound: #{paneC.bound().toString()}"
    @log "drawC: #{paneC.drawC().toString()}"
    @log "xaxis: #{paneC.xAxisC().toString()}"
    @log "yFacet:#{yfc.toString()}"
    @log "em: #{em}"

    el = _.subSvg svg, {
      class: "pane-container layer-#{layerIdx}"
      'z-index': "#{layerIdx+1}"
      transform: b2translate(paneC.bound())
      container: paneC.bound().toString()
    }

    if layerIdx is 0
      _.subSvg el, {
        width: dc.w()
        height: dc.h()
        transform: b2translate dc
        'z-index': 0
        class: 'pane-background facet-grid-background'
      }, 'rect'


    # Top Facet
    if paneC.bXFacet and layerIdx is 0
      text = env.get "xfacet-text"
      size = env.get "xfacet-size"

      xfel = _.subSvg el,
        class: "facet-label x"
        transform: b2translate xfc

      _.subSvg xfel, {
        width: xfc.w()
        height: xfc.h()
      }, "rect"

      _.subSvg(xfel, {
        x: xfc.w()/2
        y: xfc.h()
        dy: "-.5em"
        "text-anchor": "middle"
      }, "text")
        .text(text)
        .style("font-size", "#{size}pt")

    # Right Facet
    if paneC.bYFacet and layerIdx is 0
      @log env
      text = env.get "yfacet-text"
      size = env.get "yfacet-size"

      yfel = _.subSvg(el, {
        class: "facet-label y"
        transform: b2translate yfc
        container: yfc.toString()
      })

      _.subSvg(yfel, {
        width: yfc.w()
        height: yfc.h()
      }, "rect")

      yftext = _.subSvg(yfel, {
        y: "-.5em"
        x: yfc.h()/2
        "text-anchor": "middle"
        transform: "rotate(90)"
      }, "text")
        .text(text)
        .style("font-size", "#{size}pt")

    # XXX: also check if we want to show tick lines but not the labels
    # X Axis
    if layerIdx is 0
      xac2 = xac.clone()
      xael = _.subSvg el, {
        class: 'axis x'
        transform: b2translate xac2
      }

      xscale = scaleSet.scale 'x', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(xscale.d3()).orient('bottom')
      tickSize = dc.h()
      axis.tickSize -tickSize
      axis.tickFormat('') unless paneC.bXAxis

      # TODO: figure out how many ticks to render
      if xscale.type is gg.data.Schema.numeric
        axis.ticks(5)

      xael.call axis

    # Y Axis
    if layerIdx is 0
      yac2 = yac.clone()
      yac2.d yac.w(), 0
      yael = _.subSvg el, {
        class: 'axis y'
        transform: b2translate yac2
      }

      yscale = scaleSet.scale 'y', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(yscale.d3()).orient('left')
      tickSize = dc.w()
      axis.tickSize -tickSize
      axis.tickFormat('') unless paneC.bYAxis

      @log "yaxis type: #{yscale.type}"
      @log yscale.toString()

      if yscale.type is gg.data.Schema.numeric
        nticks = Math.min(5, Math.ceil(dc.h() / (1.1*em.h)))
        axis.ticks(nticks, d3.format(',.0f'), 5)
        @log "yaxis nticks #{nticks}"

      yael.call axis


    paneSvg = _.subSvg el, {
      class: 'layer-pane facet-grid'
      transform: b2translate(dc)
      width: dc.w()
      height: dc.h()
      id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}-#{layerIdx}"
    }


    # Update env
    env.get('svg').pane = paneSvg


    table




