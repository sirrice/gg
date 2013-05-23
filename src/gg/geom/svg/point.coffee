#<< gg/geom/render


class gg.geom.svg.Point extends gg.geom.Render
  @aliases = ["point", "pt"]

  defaults: (table, env) ->
    r: 5
    "fill-opacity": "0.5"
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5
    group: 1

  inputSchema: (table, env) ->
    ['x', 'y']

  render: (table, env, node) ->
    gg.wf.Stdout.print table, ['x'], 5, @log

    data = table.asArray()
    svg = @svg table, env
    circles = @agroup(svg, "circles geoms", data)
      .selectAll("circle")
      .data(data)
    enter = circles.enter()
    exit = circles.exit()
    enterCircles = enter.append("circle")

    @applyAttrs enterCircles,
      class: "geom"
      cx: (t) -> t.get('x')
      cy: (t) -> t.get('y')
      "fill-opacity": (t) -> t.get('fill-opacity')
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      fill: (t) -> t.get('fill')
      r: (t) -> t.get('r')

    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(2)
      "fill-opacity": 1
      r: (t) -> t.get('r') + 2
    cssOut =
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')
      r: (t) -> t.get('r')

    _this = @
    circles
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)


    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


