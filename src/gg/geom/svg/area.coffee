#<< gg/geom/render

class gg.geom.svg.Area extends gg.geom.Render
  @aliases = ["area"]


  defaults: (table, env) ->
    "stroke-width": 1
    stroke: "steelblue"
    fill: "grey"
    "fill-opacity": 0.7
    group: 1

  inputSchema: (table, env) -> ['pts']

  render: (table, env, node) ->
    svg = @svg table, env
    data = table.asArray()

    area = d3.svg.area()
        .x((d) -> d.x)
        .y0((d) -> d.y0)
        .y1((d) -> d.y1)
        #.interpolate('basis')

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    areas = @groups(svg, 'areas', data).selectAll('path')
        .data((d) -> [d])
    enter = areas.enter()
    enterAreas = enter.append("path")
    exit = areas.exit()

    @applyAttrs enterAreas,
      class: "path"
      d: (d) -> area(d.get 'pts')
      "stroke": (t) -> t.get "stroke"
      "stroke-width": (t) -> t.get 'stroke-width'
      "stroke-opacity": (t) -> t.get "stroke-opacity"
      fill: (t) -> t.get 'fill'
      "fill-opacity": (t) -> t.get 'fill-opacity'


    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(2)
      "fill-opacity": 1

    cssOut =
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')

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


