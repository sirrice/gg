#<< gg/geom/geom
#<< gg/geom/reparam/rect
#<< gg/geom/svg/rect

class gg.geom.Rect extends gg.geom.Geom
  @aliases: ["interval", "rect"]
  parseSpec: ->
    super

    @reparam = new gg.geom.reparam.Rect  {name: "rect-reparam"}
    @render = new gg.geom.svg.Rect  {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'
    width: 'x'


