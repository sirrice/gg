#<< gg/geom/render


class gg.geom.svg.Line extends gg.geom.Render
  @aliases = "line"

  defaults: (table) ->
    "stroke-width": 1.5
    "stroke-opacity": 0.7
    stroke: "black"
    fill: "none"
    group: '1'

  inputSchema: (table, env) -> ['pts', 'group']

  render: (table, env) ->
    svg = @svg table, env
    data = table.asArray()

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    lines = @groups(svg, 'line', data).selectAll('path')
        .data((d) -> [d])
    enter = lines.enter()
    enterLines = enter.append("path")
    exit = lines.exit()

    liner = d3.svg.line()
        .x((d) -> d.x)
        .y((d) -> d.y1)
        #.interpolate('basis')

    @log "stroke is #{table.get 0, "stroke"}"

    cssNormal =
      "stroke": (t) -> t.get("stroke")
      "stroke-width": (t) -> t.get("stroke-width")
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      "fill": "none"

    cssOver =
      stroke: (t) -> d3.rgb(t.get("fill")).darker(2)
      "stroke-width": (t) -> t.get('stroke-width') + 1
      "stroke-opacity": 1

    @applyAttrs enterLines,
      class: "geom"
      d: (d) -> liner(d.get 'pts')
    @applyAttrs enterLines,
      cssNormal


    _this = @
    lines
      .on("mouseover", (d, idx) ->
        _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->
        _this.applyAttrs d3.select(@), cssNormal)


    exit.remove()



