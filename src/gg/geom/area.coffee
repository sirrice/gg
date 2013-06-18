#<< gg/geom/geom

class gg.geom.Area extends gg.geom.Geom
  @aliases: "area"

  parseSpec: ->
    super
    @reparam = new gg.geom.reparam.Line {name: "area-reparam"}
    @render = new gg.geom.svg.Area {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'
    width: 'x'



