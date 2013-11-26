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

  svg: (md) -> md.any('svg').pane

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
    svg = @svg md

    # debugging information
    console.log "col provs"
    console.log table.colProv 'x'
    console.log table.colProv 'y'
    console.log table.colProv 'sum'
    counter = new ggutil.Counter()
    table.dfs (n, path) ->
      name = n.constructor.name
      counter.inc(name)
      counter.inc("#{name}-cost", n.timer().sum())
      counter.inc(n.name)
      counter.inc("#{n.name}-cost", n.timer().sum())
    console.log counter.toString()

    @render table, svg
    @renderDebug md, svg
    @renderInteraction md, svg

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


  renderInteraction: (md, svg) ->
    Facets = gg.facet.base.Facets
    geoms = svg.selectAll(".geom")

    # Connect events
    if no
      geoms
        .on("mouseover", () -> )
        .on("mouseout", () -> )

    if no and @constructor.brush?
      row = md.any()
      brushEventName = "brush-#{md.any 'facet-x'}"
      event = md.any "event"
      event.on brushEventName, @constructor.brush(geoms)


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

