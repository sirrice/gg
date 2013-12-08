#<< gg/geom/render

class gg.geom.svg.Dot extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Dot"
  @aliases = ["dot"]

  defaults: ->
    "fill-opacity": 0.5
    fill: "steelblue"
    stroke: "steelblue"
    r: 4
    "stroke-width": 2
    "stroke-opacity": 0.5

  inputSchema: ->
    ['x', 'y0', 'y1']

  render: (table, svg) ->
    rows = table.all()

    dots = @agroup(svg, "dots geoms", rows)
      .selectAll(".dot")
      .data(rows)
    enter = dots.enter()
    exit = dots.exit()
    enterDots = enter.append("g").classed('dot', yes)

    get = (attr) -> (t) -> t.get(attr)
    line = (t) -> "M#{t.get 'x'} #{t.get 'y0'} V #{t.get 'y1'}"

    @applyAttrs enterDots.append('circle'), {
      cx: get 'x'
      cy: get 'y'
      fill: get 'fill'
      r: get 'r'
    }

    @applyAttrs enterDots.append('path'), {
      d: line
      stroke: get('stroke')
      'stroke-width': get('stroke-width')
      "stroke-opacity": get("stroke-opacity")
      "stroke-dasharray": "5,10"
      fill: "none"
    }

    cssOver = {}
    cssOut = {
      x
    }


    _this = @
    #dots
    #.on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
    #.on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)




    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


