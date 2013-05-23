#<< gg/geom/geom

# x,y,r,x0,x1,y0,y1, ...
class gg.geom.Point extends gg.geom.Geom
  @aliases: ["point"]

  parseSpec: ->
    super
    reparamSpec =
      name: "point-reparam:#{@layer.layerIdx}"
      defaults: { r: 5 }
      inputSchema: ['x', 'y']
      map:
        x: 'x'
        y: 'y'
        r: 'r'
        x0: 'x'
        x1: 'x'
        y0: 'y'
        y1: 'y'

    @reparam = gg.xform.Mapper.fromSpec @g, reparamSpec
    @render = new gg.geom.svg.Point @layer, {}


