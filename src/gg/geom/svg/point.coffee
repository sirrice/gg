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
    group: 1

  inputSchema: ->
    ['x', 'y']

  @brush: (geoms) ->
    (extent) ->
      # extent is in pixels
      [[minx, miny], [maxx, maxy]] = extent
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

        if valid then 'black' else row.get 'fill'



  render: (table, svg) ->
    gg.wf.Stdout.print table, ['x', 'fill'], 5, @log

    rows = table.rows()
    circles = @agroup(svg, "circles geoms", rows)
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


