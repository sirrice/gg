
class gg.core.Layout extends gg.core.BForm
  @ggpackage = "gg.core.Layout"


  compute: (tables, envs, params) ->
    options = params.get 'options'
    c = new gg.core.Bound 0, 0, options.w, options.h
    [w,h] = [c.w(), c.h()]
    fw = w
    fh = h
    titleH = 0
    titleC = null
    facetC = new gg.core.Bound 0, 0, w, h


    if options.minimal
      title = options.title
      if title?
        titleH = _.exSize({'class': 'graphic-title'}).h
        titleC = new gg.core.Bound w / 2, 0
        facetC.y0 += titleH

    # TODO: layout guides


    # Add data to the environment
    lc = _.first(envs).get('lc') or {}
    lc.titleC = titleC
    lc.facetC = facetC
    lc.baseC = c
    _.each envs, (env) -> env.put('lc', lc)


    tables


