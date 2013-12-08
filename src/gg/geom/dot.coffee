#<< gg/geom/geom
#<< gg/geom/reparam/point

# x,y,r,x0,x1,y0,y1, ...
class gg.geom.Dot extends gg.geom.Geom
  @aliases: ["dot"]

  parseSpec: ->
    super
    @reparam = new gg.geom.reparam.Rect
      name: "dot-reparam:#{@layer.layerIdx}"
    @render = new gg.geom.svg.Dot {}

  posMapping: ->
    y0: 'y'
    y1: 'y'


