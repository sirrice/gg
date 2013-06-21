#<< gg/core/bform

class gg.core.Render extends gg.core.BForm
  @ggpackage = "gg.core.Render"

  parseSpec: ->
    super
    @params.put "clientonly", yes

  compute: (tables, envs, params) ->
    env = _.first envs
    console.log env
    svg = env.get('svg').base
    lc = env.get 'lc'
    c = lc.baseC
    options = params.get 'options'
    lc = _.first(envs).get('lc')
    throw Error() unless lc?


    svg
      .attr('width', c.w())
      .attr('height', c.h())


    _.subSvg svg, {
      class: 'graphic-background'
      width: '100%'
      height: '100%'
    }, 'rect'

    titleC = lc.titleC
    if titleC
      text = _.subSvg svg, {
        'text-anchor': 'middle'
        class: 'graphic-title'
        style: 'font-size: 30pt'
        dx: titleC.x0
        dy: '1em'
      }, 'text'
      text.text options.title

    facetC = lc.facetC
    facetsSvg = _.subSvg svg, {
      transform: "translate(#{facetC.x0},#{facetC.y0})"
      width: facetC.w()
      height: facetC.h()
    }

    # TODO: render guides
    guideC = lc.guideC


    # update env variables
    _.each envs, (env) ->
      env.get('svg').facets = facetsSvg

    tables

