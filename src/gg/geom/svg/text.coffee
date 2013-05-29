#<< gg/geom/render


class gg.geom.svg.Text extends gg.geom.Render
  @aliases = ["text", "label"]

  defaults: (table, env) ->
    "fill-opacity": "0.5"
    fill: "steelblue"
    dx: 10
    dy: 10
    group: 1

  inputSchema: (table, env) ->
    ['x0', 'y0', 'text']

  render: (table, env, node) ->
    gg.wf.Stdout.print table, null, 5, @log

    data = table.asArray()
    svg = @svg table, env
    texts = @agroup(svg, "text geoms", data)
      .selectAll("text")
      .data(data)
    enter = texts.enter()
    exit = texts.exit()
    enterTexts = enter.append("text")

    @applyAttrs enterTexts,
      class: "geom"
      x: (t) -> t.get('x0')
      y: (t) -> t.get('y0')
      dx: (t) -> t.get 'dx'
      dy: (t) -> t.get 'dy'
      "fill-opacity": (t) -> t.get('fill-opacity')
      fill: (t) -> t.get('fill')
    enterTexts
      .text (t) -> t.get 'text'

    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(2)
      "fill-opacity": 1
    cssOut =
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')

    _this = @
    texts
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)

    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
    .transition()
      .remove()


