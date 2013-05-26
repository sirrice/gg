#<< gg/geom/render

class gg.geom.svg.Boxplot extends gg.geom.Render
  @aliases: ["schema", "boxplot"]


  defaults: (table, env) ->
    "stroke-width": 1
    stroke: "steelblue"
    fill: d3.rgb("steelblue").brighter(2)
    "fill-opacity": 0.5

  inputSchema: (table, env) ->
    ['x','q1', 'median', 'q3', 'lower', 'upper',
      'outliers', 'min', 'max']

  render: (table, env, node) ->

    svg = @svg table, env
    data = table.asArray()

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    boxes = @agroup(svg, "boxes geoms", data)
      .selectAll("circle")
      .data(data)

    enter = boxes.enter()
      .append("g")
      .attr("class", "boxplot")
    #enterCircles = enter.append("circle")

    y = (t) -> Math.min(t.get('y0'), t.get('y1'))
    height = (t) -> Math.abs(t.get('y1') - t.get('y0'))
    width = (t) -> t.get('x1') - t.get('x0')
    #width = (t) -> t.get('width')
    x0 = (t) -> t.get 'x0'
    x1 = (t) -> t.get 'x1'
    #x0 = (t) -> t.get('x') - t.get('width') / 2.0
    #x1 = (t) -> t.get('x') + t.get('width') / 2.0




    # iqr
    iqr = @applyAttrs enter.append('rect'),
      class: "boxplot iqr"
      x: x0
      y: (t) -> Math.min(t.get('q3'), t.get('q1'))
      width: width
      height: (t) -> Math.abs(t.get('q1') - t.get('q3'))

    median = @applyAttrs enter.append('line'),
      class: "boxplot median"
      x1: x0
      x2: x1
      y1: (t) -> t.get 'median'
      y2: (t) -> t.get 'median'

    # upper whisker
    upperw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get 'x'
      x2: (t) -> t.get 'x'
      y1: (t) -> t.get 'q3'
      y2: (t) -> t.get 'upper'

    # upper tick
    uppert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get('x')-width(t)*0.2
      x2: (t) -> t.get('x')+width(t)*0.2
      y1: (t) -> t.get 'upper'
      y2: (t) -> t.get 'upper'


    # lower whisker
    lowerw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get 'x'
      x2: (t) -> t.get 'x'
      y1: (t) -> t.get 'q1'
      y2: (t) -> t.get 'lower'


    # lower tick
    lowert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get('x')-width(t)*0.2
      x2: (t) -> t.get('x')+width(t)*0.2
      y1: (t) -> t.get 'lower'
      y2: (t) -> t.get 'lower'

    circles = enter.selectAll("circle")
      .data((d) -> _.map d.get('outlier'), (outlier) ->
        {y: outlier, x: d.get('x')})
    enterCircles = circles.enter().append("circle")

    @applyAttrs enterCircles,
      class: "boxplot outlier"
      cx: (t) -> t.x
      cy: (t) -> t.y
      #"fill-opacity": (t) -> t.get('fill-opacity')
      #"stroke-opacity": (t) -> t.get("stroke-opacity")
      #fill: (t) -> t.get('fill')
      #r: (t) -> t.get('r')




    gs = [enter]# [iqr, median, upperw, uppert, lowerw, lowert]
    _.each gs, (g) =>
      cssOver =
        "fill-opacity": 1
        "stroke-opacity": 1
        fill: (t) -> d3.rgb(t.get('fill')).darker(1)
        stroke: (t) -> d3.rgb(t.get "stroke").darker(2)
        "stroke-width": (t) -> t.get("stroke-width") + 0.5

      cssOut =
        "fill-opacity": (t) -> t.get('fill-opacity')
        "stroke-opacity": (t) -> t.get("stroke-opacity")
        fill: (t) -> t.get('fill')
        stroke: (t) -> t.get "stroke"
        "stroke-width": (t) -> t.get "stroke-width"

      @applyAttrs g, cssOut
      _this = @
      g
        .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
        .on("mouseout", (d, idx) -> _this.applyAttrs d3.select(@), cssOut)



