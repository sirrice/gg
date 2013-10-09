
class gg.core.Layout extends gg.core.BForm
  @ggpackage = "gg.core.Layout"


  compute: (tset, params) ->
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
    md = tset.getMD()
    lc = _.first(md.getCol('lc')) or {}
    lc.titleC = titleC
    lc.facetC = facetC
    lc.baseC = c

    md = gg.data.Transform.transform md, {'lc': (row)->lc}
    new gg.data.PairTable tset.getTable(), md


