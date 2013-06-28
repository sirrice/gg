

class gg.facet.base.Render extends gg.core.BForm
  @ggpackage = "gg.facet.base.Render"


  parseSpec: ->
    super

    @params.ensureAll
      'svg': [[], @spec.svg]
      'fXLabel': [[], 'x facet']
      'fYLabel': [[], 'y facet']
    @params.put "clientonly", yes


  renderLabels: (tables, envs, params, lc) ->
    options = params.get 'options'
    fXLabel = params.get 'fXLabel'
    fYLabel = params.get 'fYLabel'
    svg = _.first(envs).get('svg').facets
    bgC = lc.background
    xflC = lc.xFacetLabelC
    yflC = lc.yFacetLabelC
    xalC = lc.xAxisLabelC
    yalC = lc.yAxisLabelC
    plotC = lc.plotC
    b2translate = (b) -> "transform(#{b.x0},#{b.y0})"

    _.subSvg svg, {
      class: 'plot-background'
      width: bgC.w()
      height: bgC.h()
    }, 'rect'

    if xflC?
      _.subSvg(svg, {
        transform: "translate(#{xflC.x0}, #{xflC.y0})"
        class: 'facet-title x-facet-title'
      }).append('text')
        .text(fXLabel)
        .attr('text-anchor', 'middle')

    if yflC?
      c = _.subSvg svg, {
        transform: "translate(#{yflC.x0}, #{yflC.y0})"
        class: 'facet-title y-facet-title'
        container: yflC.toString()
      }
      _.subSvg(c, {
        "text-anchor": "middle"
        transform: "rotate(90)"
        dx: ".5em"
        y: 0
        #y: yflC.h()/2
      }, 'text').text(fYLabel)

    if xalC?
      _.subSvg(svg, {
        transform: "translate(#{xalC.x0},#{xalC.y0})"
        class: "x-axis-container"
      }).append('text')
        .text(options.xaxis)
        .attr('text-anchor', 'middle')

    if yalC?
      yalSvg = _.subSvg(svg, {
        transform: "translate(#{yalC.x0},#{yalC.y0})"
        class: "y-axis-container"
        container: yalC.toString()
      })

      _.subSvg(yalSvg, {
        transform: "rotate(-90)"
        'text-anchor': 'middle'
      }, 'text').text(options.yaxis)


    wRatio = plotC.w() / bgC.w()
    hRatio = plotC.h() / bgC.h()
    transform = "#{b2translate plotC}scale(#{wRatio},#{hRatio})"
    matrix = "#{wRatio},0,0,#{hRatio},#{plotC.x0},#{plotC.y0}"
    plotSvg = _.subSvg svg, {
      transform: "matrix(#{matrix})"
      class: 'graphic-with-margin'
      container: plotC.toString()
    }

    # update environment
    _.each envs, (env) ->
      env.get('svg').plot = plotSvg





  compute: (tables, envs, params) ->
    lc = _.first(envs).get 'lc'

    @renderLabels tables, envs, params, lc

    _.each envs, (env) -> env.put 'lc', lc

    tables

  @fromSpec: (spec) ->
    new gg.facet.grid.Render spec

