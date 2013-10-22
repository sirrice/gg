#<< gg/geom/render


class gg.geom.svg.Line extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Line"
  @aliases = "line"

  defaults: ->
    "stroke-width": 1.5
    "stroke-opacity": 0.7
    stroke: "black"
    fill: "none"
    group: {}

  inputSchema:  -> ['x', 'y', 'y1', 'group']

  @linesCross: ([x0, y0, x1, y1], [xp0, yp0, xp1, yp1]) ->
    d = xp1*y1 - x1*yp1
    return no if d is 0
    s = (1/d) *  ((x0 - xp0) * y1 - (y0 - yp0) * x1)
    t = (1/d) * -(-(x0 - xp0) * yp1 + (y0 - yp0) * xp1)
    ret = s > 0 and s < 1 and t > 0 and t < 1
    #console.log ["line", ret, x0, y0, x1, y1, 'vs', xp0, yp0, xp1, yp1]
    ret

  @withinBox: (x,y, [x0, y0, x1, y1]) ->
    x0 <= x and x <= x1 and y0 <= y and y <= y1

  @lineCrossBox: (line, box) ->
    [x0, y0, x1, y1] = line
    [xp0, yp0, xp1, yp1] = box
    ret = (
      @withinBox(x0, y0, box) or
      @withinBox(x1, y1, box) or
      @linesCross(line, [xp0, yp0, xp0, yp1]) or
      @linesCross(line, [xp0, yp0, xp1, yp0]) or
      @linesCross(line, [xp1, yp1, xp0, yp1]) or
      @linesCross(line, [xp1, yp1, xp1, yp0])
    )
    #console.log [x0, y0, x1, y1, ret]
    ret


  @brush: (geoms) ->
    ([[minx, miny], [maxx, maxy]]) ->
      extent = [minx, miny, maxx, maxy]
      geoms.attr 'stroke', (d, i) ->
        l = d3.select @
        row = l.data()[0]
        pts = row.get 'pts'
        prev = _.first pts
        cur = null
        for cur in _.rest pts
          line = [prev.x, prev.y1, cur.x, cur.y1]
          if gg.geom.svg.Line.lineCrossBox(line , extent)
            return 'black'
          prev = cur
        return row.get 'stroke'


  render: (table, svg) ->
    linetables = table.partition 'group'

    lines = @groups(svg, 'line', linetables)
      .selectAll('path')
      .data((d) -> [d])
    enter = lines.enter()
    enterLines = enter.append("path")
    exit = lines.exit()

    liner = d3.svg.line()
        .x((d) -> d.get 'x')
        .y((d) -> d.get 'y1')

    @log "stroke is #{table.get 0, "stroke"}"

    cssNormal =
      "stroke": (g) -> g.get(0, 'stroke')
      "stroke-width": (g) -> g.get(0, "stroke-width")
      "stroke-opacity": (g) -> g.get(0, "stroke-opacity")
      "fill": "none"

    cssOver =
      stroke: (g) -> d3.rgb(g.get(0, "fill")).darker(2)
      "stroke-width": (g) -> g.get(0, 'stroke-width') + 1
      "stroke-opacity": 1


    @applyAttrs enterLines,
      class: "geom"
      d: (d) -> liner(d.getRows())

    @applyAttrs enterLines, cssNormal

    _this = @
    lines
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) -> _this.applyAttrs d3.select(@), cssNormal)
      #.on("brush", @constructor.brush lines)


    exit.remove()



