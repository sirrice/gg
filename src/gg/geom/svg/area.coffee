#<< gg/geom/render

class gg.geom.svg.Area extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Area"
  @aliases = ["area"]


  defaults:  ->
    "stroke-width": 1
    stroke: "steelblue"
    fill: "grey"
    "fill-opacity": 0.7

  inputSchema: -> ['x', 'y0', 'y1']

  render: (table, svg)  ->
    area = d3.svg.area()
        .x((d) -> d.get 'x')
        .y0((d) -> d.get 'y0')
        .y1((d) -> d.get 'y1')
        #.interpolate('basis')

    linetables = table.partition('group', 'table').all('table')

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    areas = @groups(svg, 'areas', linetables).selectAll('path')
        .data((d) -> [d])
    enter = areas.enter()
    enterAreas = enter.append("path")
    exit = areas.exit()

    @applyAttrs enterAreas,
      class: "path"
      d: (g) -> area g.all()
      "stroke": (g) -> g.any('stroke')
      "stroke-width": (g) -> g.any('stroke-width')
      "stroke-opacity": (g) -> g.any("stroke-opacity")
      fill: (g) -> g.any('fill')
      "fill-opacity": (g) -> g.any('fill-opacity')


    cssOver =
      fill: (g) -> d3.rgb(g.any("fill")).darker(2)
      "fill-opacity": 1

    cssOut =
      fill: (g) -> g.any('fill')
      "fill-opacity": (g) -> g.any('fill-opacity')

    _this = @
    areas
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)



    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


