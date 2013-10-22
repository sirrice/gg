#<< gg/geom/render


class gg.geom.svg.Text extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Text"
  @aliases = ["text", "label"]

  defaults: ->
    "fill-opacity": "0.5"
    fill: "steelblue"
    dx: 10
    dy: 10
    group: 1

  inputSchema: ->
    ['x0', 'y0', 'text']

  render: (table, svg) ->
    gg.wf.Stdout.print table, null, 5, @log
    rows = table.rows()

    texts = @agroup(svg, "text geoms", rows)
      .selectAll("text")
      .data(rows)
    enter = texts.enter()
    exit = texts.exit()
    enterTexts = enter.append("text")

    @applyAttrs enterTexts,
      class: "geom"
      x: (t) -> t.get 'x0'
      y: (t) -> t.get 'y0'
      dx: (t) -> t.get 'dx'
      dy: (t) -> t.get 'dy'
      "fill-opacity": (t) -> t.get 'fill-opacity'
      fill: (t) -> t.get 'fill'
    enterTexts
      .text (t) -> t.get 'text'

    cssOver =
      fill: (t) -> d3.rgb(t.get "fill").darker(2)
      "fill-opacity": 1
    cssOut =
      fill: (t) -> t.get 'fill'
      "fill-opacity": (t) -> t.get 'fill-opacity'

    _this = @
    texts
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)
      .on("brush", gg.geom.svg.Rect.brush(texts))

    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
    .transition()
      .remove()


