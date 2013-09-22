#<< gg/core/xform

class gg.facet.pane.Svg extends gg.core.BForm
  @ggpackage = "gg.facet.pane.Svg"

  parseSpec: ->
    super
    @params.put "location", "client"

  b2translate: (b) -> "translate(#{b.x0},#{b.y0})"

  renderFacetPane: (data, params) ->
    table = data.table
    env = data.env
    svg = env.get('svg').plot
    paneC = env.get 'paneC'
    eventCoordinator = env.get 'event'
    facetId = env.get gg.facet.base.Facets.facetId
    return table unless paneC?

    info = @paneInfo data, params
    layerIdx = info.layer
    scaleSet = @scales data, params
    dc = paneC.drawC()
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()
    xac = paneC.xAxisC()
    yac = paneC.yAxisC()
    xscale = scaleSet.scale 'x', gg.data.Schema.unknown
    yscale = scaleSet.scale 'y', gg.data.Schema.unknown

    @log "panec: #{paneC.toString()}"
    @log "bound: #{paneC.bound().toString()}"
    @log "drawC: #{paneC.drawC().toString()}"
    @log "xaxis: #{paneC.xAxisC().toString()}"
    @log "yFacet:#{yfc.toString()}" if yfc?
    @log "layer: #{layerIdx}"

    el = _.subSvg svg, {
      class: "pane-container layer-#{layerIdx}"
      'z-index': "#{layerIdx+1}"
      transform: @b2translate(paneC.bound())
      container: paneC.bound().toString()
    }

    @renderBg(el, dc) # render this first so it's at the bottom
    # XXX: check if show tick lines but not the labels
    @renderXAxis(el, dc, xac, xscale, {show: paneC.bXAxis})
    @renderYAxis(el, dc, yac, yscale, {show: paneC.bYAxis})
    @renderXFacet(el, xfc, env) if paneC.bXFacet 
    @renderYFacet(el, yfc, env) if paneC.bYFacet

    dataPaneSvg = _.subSvg el, {
      class: 'data-pane facet-grid'
      transform: @b2translate dc
      width: dc.w()
      height: dc.h()
      id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}"
    }

    eventName = "brush-#{facetId}"
    @renderBrushes(
      dataPaneSvg, 
      xscale, 
      yscale, 
      eventCoordinator,
      eventName)

    el


  compute: (datas, params) ->
    # first pass to create panes
    els = {}
    for data in datas
      info = @paneInfo data, params
      key = JSON.stringify [info.facetX, info.facetY]
      if key not of els
        els[key] = @renderFacetPane data, params

    # second pass sets env['svg'].paneSvg for each data

    for data in datas
      env = data.env
      paneC = env.get 'paneC'
      facetId = env.get gg.facet.base.Facets.facetId

      info = @paneInfo data, params
      layerIdx = info.layer
      key = JSON.stringify [info.facetX, info.facetY]
      dc = paneC.drawC()
      el = els[key]

      paneSvg = el.select('.data-pane').insert 'g', ':last-child'
      paneSvg.attr {
        class: 'layer-pane facet-layer-grid'
        width: dc.w()
        height: dc.h()
        id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}-#{layerIdx}"
      }
      env.get('svg').pane = paneSvg

    datas



  renderBg: (el, container) ->
    bg = el.insert 'rect', ':first-child'
    bg.attr 
      width: container.w()
      height: container.h()
      transform: @b2translate container
      'z-index': 0
      class: 'pane-background facet-grid-background'
    bg

  renderXFacet: (el, container, env) ->
    text = env.get "xfacet-text"
    size = env.get "xfacet-size"

    xfel = el.insert 'g', ':first-child'
    xfel.attr 
      class: "facet-label x"
      transform: @b2translate container

    _.subSvg xfel, {
      width: container.w()
      height: container.h()
    }, "rect"

    _.subSvg(xfel, {
      x: container.w()/2
      y: container.h()
      dy: "-.5em"
      "text-anchor": "middle"
    }, "text")
      .text(text)
      .style("font-size", "#{size}pt")

  renderYFacet: (el, container, env) ->
    text = env.get "yfacet-text"
    size = env.get "yfacet-size"

    yfel = el.insert 'g', ':first-child'
    yfel.attr
      class: "facet-label y"
      transform: @b2translate container
      container: container.toString()

    _.subSvg yfel, {
      width: container.w()
      height: container.h()
    }, 'rect'

    yftext = _.subSvg(yfel, {
      y: "-.5em"
      x: container.h()/2
      "text-anchor": "middle"
      transform: "rotate(90)"
    }, "text")
      .text(text)
      .style("font-size", "#{size}pt")


  renderXAxis: (el, dc, container, xscale, tickOpts={}) ->

      xac2 = container.clone()
      xael = el.insert 'g', ':first-child'
      xael.attr
        class: 'axis x'
        transform: @b2translate xac2

      show = if tickOpts.show? then tickOpts.show else yes
      tickSize = dc.h()
      axis = d3.svg.axis().scale(xscale.d3()).orient('bottom')
      axis.tickSize -tickSize # because y coords are reversed
      axis.tickFormat('') unless show
      nticks = 5
      d3scale = xscale.d3()
      domain = d3scale.domain()

      if xscale.type in [gg.data.Schema.numeric, xscale.type is gg.data.Schema.date]
        fmtr = axis.tickFormat or d3scale.tickFormat
        if fmtr? and _.isFunction fmtr
          fmtr = fmtr()
        else
          fmtr = String

        @log "autotuning x axis ticks"
        @log "tickFormat is function: #{_.isFunction fmtr}"
        if d3scale.ticks? and _.isFunction fmtr
          nticks = 2
          for n in _.range(1, 10)
            ticks = _.map d3scale.ticks(n), fmtr
            ticksizes = _.map ticks, (tick) ->
              gg.util.Textsize.textSize(tick,
                { class: "axis x"},
                xael[0][0]).width
            widthAtTick = _.sum ticksizes
            @log "ticks: #{JSON.stringify ticks}"
            @log "sizes: #{JSON.stringify ticksizes}"
            @log "width: #{widthAtTick}"
            if widthAtTick < dc.w()
              axis.ticks nticks
            else
              break

      else if xscale.type is gg.data.Schema.ordinal
        for n in _.range(1, 20)
          blocksize = Math.ceil(domain.length / n)
          nblocks = Math.floor(domain.length / blocksize)
          ticks = _.times nblocks, (block) -> domain[block*blocksize]
          ticksizes = _.map ticks, (tick) ->
            gg.util.Textsize.textSize(tick,
              { class: "axis x"},
              xael[0][0]).width
          widthAtTick = _.sum ticksizes
          @log "ticks: #{JSON.stringify ticks}"
          @log "sizes: #{JSON.stringify ticksizes}"
          @log "width: #{widthAtTick}"
          if widthAtTick < dc.w()
            axis.ticks n
            axis.tickValues ticks
          else
            break
        @log "final nticks: #{nticks}"

      xael.call axis


  renderYAxis: (el, dc, container, yscale, tickOpts={}) ->
      yac2 = container.clone()
      yac2.d container.w(), 0
      yael = el.insert 'g', ':first-child'
      yael.attr
        class: 'axis y'
        transform: @b2translate yac2

      show = if tickOpts.show? then tickOpts.show else yes
      axis = d3.svg.axis().scale(yscale.d3()).orient('left')
      tickSize = dc.w()
      axis.tickSize -tickSize
      axis.tickFormat('') unless show

      @log "yaxis type: #{yscale.type}"
      @log yscale.toString()

      # compute number of ticks to show

      if yscale.type is gg.data.Schema.numeric
        em = _.textSize("m", {padding: 2, class: "axis y"}, yael[0][0])
        nticks = Math.min(5, Math.ceil(dc.h() / em.h))
        axis.ticks(nticks, d3.format(',.0f'), 5)
        @log "yaxis nticks #{nticks}"

      yael.call axis



  renderBrushes: (el, xscale, yscale, eventCoordinator, eventName) ->
    # transform brushed data into pixel space
    brushf = () ->
      [[minx, miny], [maxx, maxy]] = brush.extent()
      minx = xscale.scale minx
      maxx = xscale.scale maxx
      ylim = Math.max(yscale.range()[0], yscale.range()[1])
      miny = yscale.scale miny
      maxy = yscale.scale maxy
      bigger = Math.max(miny, maxy)
      miny = Math.min(miny, maxy)
      maxy = bigger
      pixelExtent = [[minx, miny], [maxx, maxy]]

      eventCoordinator.emit eventName, pixelExtent

    brush = d3.svg.brush()
      .on('brush', brushf.bind @)
      .x(xscale.d3())
      .y(yscale.d3());

    el.append('g')
      .attr('class', 'brush')
      .call(brush)

      


