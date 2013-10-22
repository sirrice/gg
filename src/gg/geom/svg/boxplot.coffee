#<< gg/geom/render

class gg.geom.svg.Boxplot extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Boxplot"
  @aliases: ["schema", "boxplot"]


  defaults: ->
    "stroke-width": 1
    stroke: "steelblue"
    fill: d3.rgb("steelblue").brighter(2)
    "fill-opacity": 0.5
    group: {}

  inputSchema: ->
    ['x','q1', 'median', 'q3', 'lower', 'upper',
      'outlier', 'min', 'max']

  render: (table, svg) ->
    nonoutliers = table.schema.exclude 'outlier'
    boxtables = table.partition nonoutliers.cols

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    boxes = svg.append("g").classed('boxes geoms', true)
    boxes = boxes.selectAll('g')
      .data(boxtables)
    enter = boxes.enter()
      .append("g")
      .attr("class", "boxplot")

    y = (t) -> Math.min(t.get(0, 'y0'), t.get(0, 'y1'))
    height = (t) -> Math.abs(t.get(0, 'y1') - t.get(0, 'y0'))
    width = (t) -> t.get(0, 'x1') - t.get(0, 'x0')
    #width = (t) -> t.get('width')
    x0 = (t) -> t.get 0, 'x0'
    x1 = (t) -> t.get 0, 'x1'
    #x0 = (t) -> t.get('x') - t.get('width') / 2.0
    #x1 = (t) -> t.get('x') + t.get('width') / 2.0




    # iqr
    iqr = @applyAttrs enter.append('rect'),
      class: "boxplot iqr"
      x: x0
      y: (t) -> Math.min(t.get(0, 'q3'), t.get(0, 'q1'))
      width: width
      height: (t) -> Math.abs(t.get(0, 'q1') - t.get(0, 'q3'))

    median = @applyAttrs enter.append('line'),
      class: "boxplot median"
      x1: x0
      x2: x1
      y1: (t) -> t.get 0, 'median'
      y2: (t) -> t.get 0, 'median'

    # upper whisker
    upperw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get 0, 'x'
      x2: (t) -> t.get 0, 'x'
      y1: (t) -> t.get 0, 'q3'
      y2: (t) -> t.get 0, 'upper'

    # upper tick
    uppert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get(0, 'x')-width(t)*0.2
      x2: (t) -> t.get(0, 'x')+width(t)*0.2
      y1: (t) -> t.get 0, 'upper'
      y2: (t) -> t.get 0, 'upper'


    # lower whisker
    lowerw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get 0, 'x'
      x2: (t) -> t.get 0, 'x'
      y1: (t) -> t.get 0, 'q1'
      y2: (t) -> t.get 0, 'lower'


    # lower tick
    lowert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.get(0, 'x')-width(t)*0.2
      x2: (t) -> t.get(0, 'x')+width(t)*0.2
      y1: (t) -> t.get 0, 'lower'
      y2: (t) -> t.get 0, 'lower'

    circles = enter.selectAll("circle")
      .data((d) -> 
        d.getRows().filter (row) -> 
          _.isValid(row.get('outlier')))
    enterCircles = circles.enter().append("circle")

    @applyAttrs enterCircles,
      class: "boxplot outlier"
      cx: (t) -> t.get 'x'
      cy: (t) -> t.get 'outlier'


    gs = [enter]# [iqr, median, upperw, uppert, lowerw, lowert]
    _.each gs, (g) =>
      cssOver =
        "fill-opacity": 1
        "stroke-opacity": 1
        fill: (t) -> d3.rgb(t.get(0, 'fill')).darker(1)
        stroke: (t) -> d3.rgb(t.get 0, "stroke").darker(2)
        "stroke-width": (t) -> t.get(0, "stroke-width") + 0.5

      cssOut =
        "fill-opacity": (t) -> t.get(0, 'fill-opacity')
        "stroke-opacity": (t) -> t.get(0, "stroke-opacity")
        fill: (t) -> t.get(0, 'fill')
        stroke: (t) -> t.get 0, "stroke"
        "stroke-width": (t) -> t.get 0, "stroke-width"

      @applyAttrs g, cssOut
      _this = @
      g
        .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
        .on("mouseout", (d, idx) -> _this.applyAttrs d3.select(@), cssOut)



