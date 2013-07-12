
class gg.core.Layout extends gg.core.BForm
  @ggpackage = "gg.core.Layout"


  compute: (datas, params) ->
    tables = _.map datas, (d) -> d.table
    envs = _.map datas, (d) -> d.env
    options = params.get 'options'
    c = new gg.core.Bound 0, 0, options.w, options.h
    [w,h] = [c.w(), c.h()]
    fw = w
    fh = h
    titleH = 0
    titleC = null
    facetC = new gg.core.Bound 0, 0, w, h


    @log options
    unless options.minimal
      title = options.title
      if title?
        textSize = _.textSize title,
          class: "graphic-title"
          padding: 2
        titleH = textSize.h * 1.1
        titleC = new gg.core.Bound w / 2, 0, w/2, titleH
        facetC.y0 += titleH

    # TODO: layout guides


    # Add containers to the environment
    lc = _.first(envs).get('lc') or {}
    lc.titleC = titleC
    lc.facetC = facetC
    lc.baseC = c
    _.each envs, (env) -> env.put('lc', lc)


    datas


