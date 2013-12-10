#<< gg/geom/render


class gg.geom.svg.Point extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Point"
  @aliases = ["point", "pt"]

  defaults: ->
    r: 2
    "fill-opacity": "0.5"
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5

  inputSchema: ->
    ['x', 'y']

  @brush: (geoms, emit=()->) ->
    (extent) ->
      # extent is in pixels
      [[minx, miny], [maxx, maxy]] = extent
      selected = []
      geoms.attr 'fill', (d, i) ->
        c = d3.select @
        row = c.datum()
        fill = row.get 'fill'
        x = row.get 'x'
        y = row.get 'y'
        
        valid = (
          minx <= x and
          maxx >= x and
          miny <= y and
          maxy >= y
        )

        if valid
          selected.push c

        if valid then 'black' else row.get 'fill'
      emit selected



  render: (table, svg) ->
    rows = table.all()
    circles = svg.append('g').classed('circles geoms', true)
      .selectAll("circle")
      .data(rows)
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
      #.on("brush", @constructor.brush circles)


    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


