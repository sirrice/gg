
class gg.core.Layout extends gg.core.BForm
  @ggpackage = "gg.core.Layout"


  compute: (pt, params) ->
    options = params.get 'options'
    c = new gg.util.Bound 0, 0, options.w, options.h
    [w,h] = [c.w(), c.h()]
    fw = w
    fh = h
    titleH = 0
    titleC = null
    facetC = new gg.util.Bound 0, 0, w, h


    @log options
    unless options.minimal
      title = options.title
      if title?
        textSize = _.textSize title,
          class: "graphic-title"
          padding: 2
        titleH = textSize.h * 1.1
        titleC = new gg.util.Bound w / 2, 0, w/2, titleH
        facetC.y0 += titleH

    # TODO: layout guides


    # Add containers to the environment
    md = pt.right()
    lc = {}
    lc = md.any('lc') if md.has 'lc'
    lc.titleC = titleC
    lc.facetC = facetC
    lc.baseC = c

    md = md.setColVal 'lc', lc
    pt.right md
    pt


