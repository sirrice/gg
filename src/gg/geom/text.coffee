#<< gg/geom/geom

class gg.geom.Text extends gg.geom.Geom
  @aliases: ["text", "label"]

  parseSpec: ->
    super

    @reparam = new gg.geom.reparam.Text @g,
      name: "text-reparam:#{@layer.layerIdx}"
    @render = new gg.geom.svg.Text @layer, {}

  posMapping: ->
    ys = ["y", "y0", "y1"]
    xs = ["x", "x0", "x1"]
    map = {}
    _.each ys, (y) -> map[y] = 'y'
    _.each xs, (x) -> map[x] = 'x'
    map




