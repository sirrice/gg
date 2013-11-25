#<< gg/geom/geom
#<< gg/geom/reparam/bin2d
#<< gg/geom/svg/rect

class gg.geom.Bin2D extends gg.geom.Geom
  @aliases: ["bin2d"]
  parseSpec: ->
    super

    padding = +@spec.padding or 0.0
    @reparam = new gg.geom.reparam.Bin2D
      name: "bin2d-reparam"
      params:
        padding: padding

    @render = new gg.geom.svg.Rect  {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'
    width: 'x'



