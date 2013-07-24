#<< gg/geom/geom
#<< gg/geom/reparam/point

# x,y,r,x0,x1,y0,y1, ...
class gg.geom.Point extends gg.geom.Geom
  @aliases: ["point"]

  parseSpec: ->
    super
    @reparam = new gg.geom.reparam.Point(
      name: "point-reparam:#{@layer.layerIdx}"
    )
    @render = new gg.geom.svg.Point {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'


