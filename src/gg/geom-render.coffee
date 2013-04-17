#<< gg/xform

#
# group attribute
#
class gg.GeomRender extends gg.XForm
  constructor: (@layer, @spec={}) ->
    @spec.name = findGoodAttr @spec, ['name'], @constructor.name
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
    klasses = [
      gg.GeomRenderPointSvg,
      gg.GeomRenderLineSvg,
      gg.GeomRenderRectSvg
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret


  @fromSpec: (layer, spec) ->
    klasses = gg.GeomRender.klasses()
    if _.isString spec
      type = spec
      spec = {type: type}
    else
      type = findGoodAttr spec, ['geom', 'type', 'shape'], 'point'
    console.log klasses
    klass = klasses[type] or gg.GeomRenderPointSvg
    console.log "geom-render klass #{type} -> #{klass.name}"
    new klass layer, spec




class gg.GeomRenderPointSvg extends gg.GeomRender
  @aliases = ["point", "pt"]

  defaults: (table, env) ->
    r: 2
    "fill-opacity": "0.5"
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5
    group: 1

  inputSchema: (table, env) ->
    ['x', 'y']

  render: (table, env, node) ->

    data = table.asArray()
    svg = @svg table, env
    circles = @agroup(svg, "circles geoms", data)
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


    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()





class gg.GeomRenderRectSvg extends gg.GeomRender
  @aliases = "rect"

  defaults: (table, env) ->
    "fill-opacity": 0.5
    fill: "steelblue"
    stroke: "steelblue"
    "stroke-width": 0
    "stroke-opacity": 0.5
    group: 1

  inputSchema: (table, env) ->
    ['x0', 'x1', 'y0', 'y1']

  render: (table, env, node) ->
    console.log 'rendering rectangles!'

    data = table.asArray()
    rects = @agroup(@svg(table, env), "intervals geoms", data)
      .selectAll("rect")
      .data(data)
    enter = rects.enter()
    exit = rects.exit()
    enterRects = enter.append("rect")

    y = (t) -> Math.min(t.get('y0'), t.get('y1'))
    height = (t) -> Math.abs(t.get('y1') - t.get('y0'))
    width = (t) -> t.get('x1') - t.get('x0')

    @applyAttrs enterRects,
      class: "geom"
      x: (t) -> t.get('x0')
      y: y
      width: width
      height: height
      "fill-opacity": (t) -> t.get('fill-opacity')
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      fill: (t) -> t.get('fill')

    cssOver =
      x: (t) -> t.get('x0') - width(t) * 0.05
      width: (t) -> width(t) * 1.1
      fill: (t) -> d3.rgb(t.get("fill")).darker(2)
      "fill-opacity": 1

    cssOut =
      x: (t) -> t.get('x0')
      width: width
      fill: (t) -> t.get('fill')
      "fill-opacity": (t) -> t.get('fill-opacity')

    _this = @
    rects
      .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
      .on("mouseout", (d, idx) ->  _this.applyAttrs d3.select(@), cssOut)



    exit.transition()
      .duration(500)
      .attr("fill-opacity", 0)
      .attr("stroke-opacity", 0)
    .transition()
      .remove()


class gg.GeomRenderLineSvg extends gg.GeomRender
  @aliases = "line"

  defaults: (table) ->
    "stroke-width": 1
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


    @applyAttrs enterLines,
      class: "geom"
      d: (d) -> liner(d.get 'pts')
      "stroke": (t) -> t.get("stroke")
      "stroke-width": (t) -> t.get("stroke-width")
      "stroke-opacity": (t) -> t.get("stroke-opacity")
      "fill": "none"


    exit.remove()


class gg.GeomRenderAreaSvg extends gg.GeomRender
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
    console.log "table has #{table.nrows()} rows"

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



class gg.GeomRenderPath extends gg.GeomRender
class gg.GeomRenderPolygon extends gg.GeomRender
class gg.GeomRenderSchema extends gg.GeomRender
class gg.GeomRenderGlyph extends gg.GeomRender

