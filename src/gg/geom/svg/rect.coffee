#<< gg/geom/render

class gg.geom.svg.Rect extends gg.geom.Render
  @aliases = "rect"

  defaults: (table, env) ->
    "fill-opacity": 0.5
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5
    group: 1

  inputSchema: (table, env) ->
    ['x0', 'x1', 'y0', 'y1']

  render: (table, env, node) ->

    data = table.asArray()
    rects = @agroup(@svg(table, env), "intervals geoms", data)
      .selectAll("rect")
      .data(data)
    enter = rects.enter()
    exit = rects.exit()
    enterRects = enter.append("rect")

    y = (t) -> Math.min(t.get('y0'), t.get('y1'))
    height = (t) -> Math.abs(t.get('y1') - t.get('y0'))
    width = (t) -> t.get('x1') - t.get('x0')

    @applyAttrs enterRects,
      class: "geom"
      x: (t) -> t.get('x0')
      y: y
      width: width
      height: height
      "fill-opacity": (t) -> t.get('fill-opacity')
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      fill: (t) -> t.get('fill')

    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(1)
      "fill-opacity": 1

    cssOut =
      x: (t) -> t.get('x0')
      width: width
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')

    _this = @
    rects
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)



    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


