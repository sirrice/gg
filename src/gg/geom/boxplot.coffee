#<< gg/geom/geom
#<< gg/geom/svg/boxplot
#<< gg/geom/reparam/boxplot

class gg.geom.Boxplot extends gg.geom.Geom
  @aliases: ["schema", "boxplot"]

  parseSpec: ->
    super

    @reparam = new gg.geom.reparam.Boxplot
      name: "schema-reparam:#{@layer.layerIdx}"
    @render = new gg.geom.svg.Boxplot  {}

  posMapping: ->
    ys = ['q1', 'median', 'q3', 'lower', 'upper',
      'min', 'max', 'lower', 'upper', 'outlier']
    xs = ['x', 'x0', 'x1']
    map = {}
    _.each ys, (y) -> map[y] = 'y'
    _.each xs, (x) -> map[x] = 'x'
    map


  scaleConfigs: ->
    x: 'ordinal'
