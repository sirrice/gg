#<< gg/geom/geom
#<< gg/geom/reparam/rect
#<< gg/geom/svg/rect

class gg.geom.Rect extends gg.geom.Geom
  @aliases: ["interval", "rect"]
  parseSpec: ->
    super

    spec = _.clone @spec
    spec.name = "rect-reparam"
    @reparam = new gg.geom.reparam.Rect spec
    @render = new gg.geom.svg.Rect  {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'
    width: 'x'


