#<< gg/core/xform


#
# group attribute
#
class gg.geom.Render extends gg.core.XForm
  @ggpackage = "gg.geom.Render"

  constructor: (@spec={}) ->
    @spec.name = @spec.name or "render-#{@constructor.name}"
    super

  parseSpec: ->
    super
    @params.put "location", "client"

  svg: (mdrow) -> mdrow.get('svg').pane

  groups: (g, klass, rows) ->
    g.selectAll("g.#{klass}")
      .data(rows)
      .enter()
      .append('g')
      .classed(klass, true)

  agroup: (g, klass, rows) ->
    g.append("g")
      .classed(klass, true)
      .data(rows)


  # given a dictionary of attributes, add them to the dom element
  applyAttrs: (domEl, attrs) ->
    _.each attrs, (val, attr) -> domEl.attr attr, val
    domEl

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    mdrow = md.any()
    svg = @svg mdrow
    facetId = gg.facet.base.Facets.row2facetId mdrow


    i = 0
    table.bfs (n) -> i += 1
    console.log "#{i} nodes in table tree"
    console.log data.Table.timer.toString 100
    for name, errs of data.Table.timer._traces
      for err in errs
        console.log err.stack
    console.log [
      'getkey: ',
      data.Table.timer.sum('getkey'),
      data.Table.timer.count('getkey'),
      data.Table.timer.avg('getkey')
    ]

    @render table, svg
    @renderDebug md, svg
    @renderInteraction mdrow, svg, table

    pairtable

  # @override this
  render: (table, rows) -> throw Error("#{@name}.render() not implemented")


  renderDebug: (md, svg) ->
    # Render some debugging info
    if @log.level == gg.util.Log.DEBUG
      write = (text, opts={}) ->
        _.subSvg(svg, opts, "text").text(text)
      write md.any('facet-x'), {dy: "1em"}
      write md.any('facet-y'), {dy: "2em"}
      write md.any(table.nrows()), {dy: "3em"}


  renderInteraction: (mdrow, svg, table) ->
    Facets = gg.facet.base.Facets
    facetId = Facets.row2facetId mdrow
    geoms = svg.selectAll(".geom")

    # Connect events
    if no
      geoms
        .on("mouseover", () -> )
        .on("mouseout", () -> )

    if @constructor.brush?
      brushEventName = "brush-#{facetId}"
      event = mdrow.get "event"
      roots = table.roots()
      prov = (ids) ->
        ret = []
        for root in roots
          filtered = root.filter (row) -> row.id in ids
          filtered.each (row) -> ret.push row
        ret
      emitSelected = (selected) -> 
        event.emit "select-#{facetId}",  selected, prov
        event.emit "select", selected, prov
      event.on brushEventName, @constructor.brush(geoms, emitSelected)


  @klasses: ->
    klasses = _.compact [
      gg.geom.svg.Point
      gg.geom.svg.Line
      gg.geom.svg.Rect
      gg.geom.svg.Area
      gg.geom.svg.Boxplot
      gg.geom.svg.Text
    ]
    ret = {}
    _.each klasses, (klass) ->
      for alias in _.flatten [klass.aliases]
        ret[alias] = klass
    ret

  @fromSpec: (spec) ->
    klasses = gg.geom.Render.klasses()
    klass = klasses[spec.type]
    return null unless klass?
    new klass spec










class gg.geom.GeomRenderPath extends gg.geom.Render
class gg.geom.GeomRenderPolygon extends gg.geom.Render
class gg.geom.GeomRenderGlyph extends gg.geom.Render

