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

    linetables = table.partition 'group'


    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    areas = @groups(svg, 'areas', linetables).selectAll('path')
        .data((d) -> [d])
    enter = areas.enter()
    enterAreas = enter.append("path")
    exit = areas.exit()

    @applyAttrs enterAreas,
      class: "path"
      d: (t) -> area(t.getRows())
      "stroke": (g) -> g.get(0, 'stroke')
      "stroke-width": (g) -> g.get(0, 'stroke-width')
      "stroke-opacity": (g) -> g.get(0, "stroke-opacity")
      fill: (g) -> g.get(0, 'fill')
      "fill-opacity": (g) -> g.get(0, 'fill-opacity')


    cssOver =
      fill: (g) -> d3.rgb(g.get(0, "fill")).darker(2)
      "fill-opacity": 1

    cssOut =
      fill: (g) -> g.get(0, 'fill')
      "fill-opacity": (g) -> g.get(0, 'fill-opacity')

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


