#<< gg/geom/render

class gg.geom.svg.Rect extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Rect"
  @aliases = ["rect", 'box']

  defaults: ->
    "fill-opacity": 0.5
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 1
    "stroke-opacity": 0.5

  inputSchema: ->
    ['x0', 'x1', 'y0', 'y1']

  # args are in pixels
  @brush: (geoms, emit=()->) ->


    ([[minx, miny], [maxx, maxy]]) ->
      selectedGeoms = []
      geoms.attr 'fill', (d, i) ->
        r = d3.select @
        row = r.datum()
        x0 = row.get 'x0'
        y0 = row.get 'y0'
        x1 = row.get 'x1'
        y1 = row.get 'y1'
        [x0, x1] = [Math.min(x0, x1), Math.max(x0, x1)]
        [y0, y1] = [Math.min(y0, y1), Math.max(y0, y1)]

        valid = not (
          x1 < minx or
          x0 > maxx or
          y1 < miny or
          y0 > maxy
        )

        if valid
          selectedGeoms.push r

        if valid then 'black' else row.get 'fill'
      emit selectedGeoms




  render: (table, svg) ->
    rows = table.all()

    rects = @agroup(svg, "intervals geoms", rows)
      .selectAll("rect")
      .data(rows)
    enter = rects.enter()
    exit = rects.exit()
    enterRects = enter.append("rect")

    x = (t) -> t.get 'x0'
    y = (t) -> Math.min(t.get('y0'), t.get('y1'))
    height = (t) -> Math.abs(t.get('y1') - t.get('y0'))
    width = (t) -> t.get('x1') - t.get('x0')

    @applyAttrs enterRects, {
      foo: (t) -> t.svg = d3.select(@)
      class: "geom"
      x
      y
      width
      height
      stroke: (t) -> t.get('stroke')
      'stroke-width': (t) -> t.get('stroke-width')
      "fill-opacity": (t) -> t.get('fill-opacity')
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      fill: (t) -> t.get('fill')
    }

    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(1)
      "fill-opacity": 1
    cssOut = {
      x
      width
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')
    }


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


