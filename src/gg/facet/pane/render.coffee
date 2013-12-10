#<< gg/core/xform

class gg.facet.pane.Svg extends gg.core.BForm
  @ggpackage = "gg.facet.pane.Svg"

  parseSpec: ->
    super
    @params.put "location", "client"

  @b2translate: (b) -> "translate(#{b.x0},#{b.y0})"
  b2translate: (b) -> @constructor.b2translate b

  renderFacetPane: (md, params) ->
    row = md.any()
    paneC = row.get 'paneC'
    return null unless paneC?

    layerIdx = row.get 'layer'
    scaleSet = row.get 'scales'
    dc = paneC.drawC()
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()
    xac = paneC.xAxisC()
    yac = paneC.yAxisC()
    xscale = scaleSet.scale 'x', data.Schema.unknown
    yscale = scaleSet.scale 'y', data.Schema.unknown

    svg = row.get('svg').plot
    eventCoordinator = row.get 'event'
    facetId = gg.facet.base.Facets.row2facetId row
    paneId = "facet-grid-#{paneC.xidx}-#{paneC.yidx}"

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
    @renderXAxis(el, dc, xac, xscale, row.get('xaxistext-opts'), params.get('tickOpts'))
    @renderYAxis(el, dc, yac, yscale, row.get('yaxistext-opts'), params.get('tickOpts'))

    dataPaneSvg = @renderDrawingPane(el, dc, paneC, paneId)
    @renderBrushes dataPaneSvg, xscale, yscale, eventCoordinator, facetId
    @renderXFacet(el, xfc, md) if paneC.xFacetH > 0
    @renderYFacet(el, yfc, md) if paneC.yFacetW > 0
    el


  renderBg: (el, container) ->
    bg = el.insert 'rect', ':first-child'
    bg.attr 
      width: container.w()
      height: container.h()
      transform: @b2translate container
      'z-index': 0
      class: 'pane-background facet-grid-background'
    bg


  renderDrawingPane: (el, dc, paneC, paneId, facetId) ->
    dataClip = el.append('clipPath')
    dataClip.attr("id", "dataclip-#{@id}")
    _.subSvg dataClip, {
      width: dc.w()
      height: dc.h()
    }, "rect"
    dataPaneSvg = _.subSvg el, {
      class: 'data-pane facet-grid'
      transform: @b2translate dc
      width: dc.w()
      height: dc.h()
      id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}"
      "clip-path": "url(#dataclip-#{@id})"
    }
    dataPaneSvg


  renderXFacet: (el, container, md) ->
    opts = md.any 'xfacettext-opts'
    text = opts.text
    size = opts.size

    #xfel = el.insert 'g', ':first-child'
    xfel = el.append 'g'
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
      dy: "-.25em"
      "text-anchor": "middle"
    }, "text")
      .text(text)
      .style("font-size", "#{size}pt")

  renderYFacet: (el, container, md) ->
    opts = md.any 'yfacettext-opts'
    text = opts.text
    size = opts.size

    #yfel = el.insert 'g', ':first-child'
    yfel = el.append 'g'
    yfel.attr
      class: "facet-label y"
      transform: @b2translate container
      container: container.toString()

    _.subSvg yfel, {
      width: container.w()
      height: container.h()
    }, 'rect'

    yftext = _.subSvg(yfel, {
      y: "-.25em"
      x: container.h()/2
      "text-anchor": "middle"
      transform: "rotate(90)"
    }, "text")
      .text(text)
      .style("font-size", "#{size}pt")


  # @param dc draw container for the entire drawing plot area
  # @param container bounds for the xaxis
  # @param opts axis formatting options computed from facet layout
  renderXAxis: (el, dc, container, xscale, opts, tickOpts={}) ->
    return if container.h() == 0
    xac2 = container.clone()

    # content is clipped _before_ transformations
    clip = el.append "clipPath"
    clip.attr
      id: "xaxisclip-#{@id}"
    cliprect = clip.append('rect')
    cliprect.attr
      x: "0"
      y: "-.5em"
      width: xac2.h()
      height: xac2.w()

    xael = el.append 'g'
    xael.attr
      class: 'axis x'
      transform: @b2translate xac2

    showTicks = if tickOpts.show? then tickOpts.show else yes
    axis = d3.svg.axis().scale(xscale.d3()).orient('bottom')
    axis.tickSize -dc.h()
    # if showticks == false, then don't allocate space in axis.layout
    axis.tickFormat opts.formatter
    axis.tickFormat('') unless showTicks


    if xscale.type in [data.Schema.numeric, xscale.type is data.Schema.date]
      axis.ticks opts.nticks

      # TODO: log scales should not be sampled evenly, need to compute
      # range locations to pick stratified sample
      
      # log scales doesn't pick ticks, need to pick ourselves
      labels = _.sample xscale.d3().ticks(opts.nticks), opts.nticks
      axis.tickValues labels

    else if xscale.type is data.Schema.ordinal
      labels = _.sample xscale.d3().domain(), opts.nticks
      axis.tickValues labels

    xael.call axis
    if opts.rotate
      xael.selectAll("text")
        .style('text-anchor', 'start')
        .attr(
          transform: 'rotate(90)'
          dy: '0em'
          dx: '.5em'
          "clip-path": "url(#xaxisclip-#{@id})"
          )

  renderYAxis: (el, dc, container, yscale, opts, tickOpts={}) ->
    return if container.w() == 0
    yac2 = container.clone()
    yac2.d container.w(), 0

    # content is clipped _before_ transformations
    clip = el.append "clipPath"
    clip.attr
      id: "yaxisclip-#{@id}"
    cliprect = clip.append('rect')
    cliprect.attr
      x: "#{-yac2.w()}px"
      y: "-1em"
      width: "#{yac2.w()}px"
      height: '2em'

    yael = el.append 'g'
    yael.attr
      class: 'axis y'
      transform: @b2translate yac2

    show = if tickOpts.show? then tickOpts.show else yes
    axis = d3.svg.axis().scale(yscale.d3()).orient('left')
    axis.tickSize -dc.w()
    axis.tickFormat opts.formatter
    axis.tickFormat('') unless show

    @log "yaxis type: #{yscale.type}"
    @log yscale.toString()

    # compute number of ticks to show
    if yscale.type in [data.Schema.numeric, data.Schema.date]
      axis.ticks opts.nticks

      # TODO: log scales should not be sampled evenly, need to compute
      # range locations to pick stratified sample

      # log scales doesn't pick ticks, need to pick ourselves
      labels = _.sample yscale.d3().ticks(opts.nticks), opts.nticks
      axis.tickValues labels

    else if yscale.type is data.Schema.ordinal
      labels = _.sample yscale.d3().domain(), opts.nticks
      axis.tickValues labels

    yael.call axis
    yael.selectAll('text').attr
      "clip-path": "url(#yaxisclip-#{@id})"



  renderBrushes: (el, xscale, yscale, eventCoordinator, facetId) ->
    eventName = "brush-#{facetId}"

    # transform brushed data into pixel space
    brushf = () ->
      [[minx, miny], [maxx, maxy]] = brush.extent()
      minx = xscale.scale minx
      maxx = xscale.scale maxx
      miny = yscale.scale miny
      maxy = yscale.scale maxy
      [miny, maxy] = [Math.min(miny, maxy), Math.max(miny, maxy)]
      pixelExtent = [[minx, miny], [maxx, maxy]]

      eventCoordinator.emit eventName, pixelExtent

    brush = d3.svg.brush()
      .on('brush', brushf)
      .x(xscale.d3())
      .y(yscale.d3());

    el.append('g')
      .attr('class', 'brush')
      .call(brush)

      

  compute: (pairtable, params) ->
    md = pairtable.right()

    # 
    # 1st pass to create panes, which includes g.data-pane.  
    # This is where geoms in each layer will be rendered
    #
    els = {}
    timer = new ggutil.Timer()
    timer.start("partition")
    partitions = md.partition(['facet-x', 'facet-y']).all('table')
    timer.stop("partition")
    els = _.o2map partitions, (p) => 
      row = p.any()
      facetId = gg.facet.base.Facets.row2facetId row
      svg = @renderFacetPane p, params
      if svg? 
        [facetId, svg] 
    start = Date.now()

    #
    # Second pass sets ['svg'].paneSvg for each data
    # and adds g.layer-pane for each layer
    #
    f = (paneC, facetx, facety, layerIdx, svg) ->
      dc = paneC.drawC()
      facetId = gg.facet.base.Facets.getFacetId facetx, facety
      el = els[facetId]

      paneSvg = el.select('.data-pane').insert 'g', ':last-child'
      paneSvg.attr {
        class: 'layer-pane facet-layer-grid'
        width: dc.w()
        height: dc.h()
        id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}-#{layerIdx}"
        container: gg.facet.pane.Svg.b2translate(paneC.bound())
      }
      svg = _.o2map svg, (v, k) -> [k,v]
      svg.pane = paneSvg
      svg

    timer.start("secondpass")
    md = md.project [{
      alias: 'svg'
      cols: ['paneC', 'facet-x', 'facet-y', 'layer', 'svg']
      f: f
      type: data.Schema.object
    }]
    md.all()
    timer.stop("secondpass")
    pairtable.right md
    pairtable


