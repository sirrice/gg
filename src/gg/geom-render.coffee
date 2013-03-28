#<< gg/geom

#
# group attribute
#
class gg.GeomRender extends gg.XForm
  constructor: (@layer, @spec={}) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super

  svg: (table, env, node) ->
    info = @paneInfo table, env
    @g.facets.svgPane info.facetX, info.facetY



  groups: (g, klass, data) ->
    g.selectAll("g.#{klass}")
      .data(data)
      .enter()
      .append('g')
      .attr('class', "#{klass}")

  agroup: (g, klass, data) ->
    g.append("g")
      .attr("class", "#{klass}")
      .data(data)


  # given a dictionary of attributes, add them to the dom element
  applyAttrs: (domEl, attrs) ->
    _.each attrs, (val, attr) -> domEl.attr attr, val

  compute: (table, env, node) -> @render table, env, node

  # @override this
  render: (table) -> throw Error("#{@name}.render() not implemented")

  @klasses: ->
    point: gg.GeomRenderPointSvg
    line: gg.GeomRenderLineSvg

  @fromSpec: (layer, spec) ->
    klasses = gg.GeomRender.klasses()
    if _.isString spec
      type = spec
      spec = {type: type}
    else
      type = findGood [spec.geom, spec.type, spec.shape, "point"]
    klass = klasses[type] or gg.GeomRenderPointSvg
    new klass layer, spec




class gg.GeomRenderPointSvg extends gg.GeomRender
  @name = "point"

  defaults: (table, env) ->
    r: 2
    "fill-opacity": 0.5
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5
    group: 1

  inputSchema: (table, env) ->
    ['x', 'y']

  render: (table, env, node) ->

    data = table.asArray()
    circles = @agroup(@svg(table, env), "circles geoms", data)
      .selectAll("circle")
      .data(data)
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

    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()






class gg.GeomRenderLineSvg extends gg.GeomRender
  @name = "line"

  defaults: (table) ->
    stroke-width: 1
    stroke: "black"

  inputSchema: (table, env) -> ['x1', 'y1', 'x2', 'y2']

  render: (table, env) ->
    lines = @groups(@svg(table, env), "lines geoms", table.asArray())
      .selectAll("line")
      .data(Object)
    enter = lines.enter()
    exit = lines.exit()
    enterLines = enter.append("line")

    @applyAttrs enterLines,
      class: "geom"
      x1: (t) -> t.get('x1')
      x2: (t) -> t.get('x2')
      y1: (t) -> t.get('y1')
      y2: (t) -> t.get('y2')
      "stroke": (t) -> t.get("stroke")
      "stroke-width": (t) -> t.get("stroke-width")
      "stroke-opacity": (t) -> t.get("stroke-opacity")

    exit.remove()



class gg.GeomRenderPath extends gg.GeomRender
class gg.GeomRenderPolygon extends gg.GeomRender
class gg.GeomRenderSchema extends gg.GeomRender
class gg.GeomRenderGlyph extends gg.GeomRender

