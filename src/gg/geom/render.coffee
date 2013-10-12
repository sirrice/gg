#<< gg/core/xform


#
# group attribute
#
class gg.geom.Render extends gg.core.XForm
  @ggpackage = "gg.geom.Render"

  parseSpec: ->
    super
    @params.put "location", "client"

  svg: (md) -> md.get(0, 'svg').pane

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
    table = pairtable.getTable()
    md = pairtable.getMD()
    svg = @svg md
    Facets = gg.facet.base.Facets
    gg.wf.Stdout.print table, null, 2, @log

    @render table, svg

    # Render some debugging info
    if @log.level == gg.util.Log.DEBUG
      write = (text, opts={}) ->
        _.subSvg(svg, opts, "text").text(text)
      write env.get(Facets.facetXKey), {dy: "1em"}
      write env.get(Facets.facetYKey), {dy: "2em"}
      write env.get(table.nrows()), {dy: "3em"}


    geoms = svg.selectAll(".geom")

    # Connect events
    if false
      geoms
        .on("mouseover", () -> )
        .on("mouseout", () -> )

    if @constructor.brush?
      brushEventName = "brush-#{env.get Facets.facetId}"
      event = env.get "event"
      event.on brushEventName, @constructor.brush(geoms)

    pairtable

  # @override this
  render: (table, rows) -> throw Error("#{@name}.render() not implemented")

  @klasses: ->
    klasses = [
      gg.geom.svg.Point
      gg.geom.svg.Line
      gg.geom.svg.Rect
      gg.geom.svg.Area
      gg.geom.svg.Boxplot
      gg.geom.svg.Text
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret


  @fromSpec: (spec) ->
    klasses = gg.geom.Render.klasses()
    if _.isString spec
      type = spec
      spec = {type: type}
    else
      type = _.findGoodAttr spec, ['geom', 'type', 'shape'], 'point'

    klass = klasses[type] or gg.geom.svg.Point
    gg.util.Log.logger(@ggpackage, "Render") "Render klass #{type} -> #{klass.name}"
    new klass spec










class gg.geom.GeomRenderPath extends gg.geom.Render
class gg.geom.GeomRenderPolygon extends gg.geom.Render
class gg.geom.GeomRenderGlyph extends gg.geom.Render

