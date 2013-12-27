#<< gg/geom/render


class gg.geom.svg.Point extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Point"
  @aliases = ["point", "pt"]

  defaults: ->
    shape: 'circle'
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
          selected.push row

        if valid 
          return d3.rgb(row.get('fill')).darker(2);
        else
          return row.get 'fill'
      emit selected



  render: (table, svg) ->
    rows = table.all() #.rows
    _id = @id


    points = svg.append('g').classed('geoms', true)
      .selectAll(".geom")
      .data(rows)
    enter = points.enter()
    exit = points.exit()
    enterPoints = enter.append('path')
    symbol = d3.svg.symbol()

    @applyAttrs enterPoints,
      class: "geom"
      transform: (t) -> "translate(#{t.get 'x'}, #{t.get 'y'})"
      d: (t) -> symbol.size(t.get('r')*t.get('r')).type(t.get 'shape')()
      stroke: (t) -> t.get 'stroke'
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')


    cssOver =
      fill: (t) -> d3.rgb(t.get("fill")).darker(2)
      "fill-opacity": 1
    cssOut =
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')

    _this = @
    points
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)


    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


    table.project {
      alias: 'el'
      cols: '*'
      type: data.Schema.object
      f: (row, idx) -> enterPoints[0][idx]
    }




