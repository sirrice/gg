#<< gg/geom/geom
#<< gg/geom/reparam/line
#<< gg/geom/svg/line

class gg.geom.Line extends gg.geom.Geom
  @aliases: "line"

  parseSpec: ->
    super
    @reparam = new gg.geom.reparam.Line {name: "line-reparam"}
    @render = new gg.geom.svg.Line {}

  posMapping: ->
    y0: 'y'
    y1: 'y'
    x0: 'x'
    x1: 'x'
    width: 'x'




