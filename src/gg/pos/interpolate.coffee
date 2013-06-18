#<< gg/pos/position


class gg.pos.Interpolate extends gg.pos.Position
  @ggpackage = "gg.pos.Interpolate"
  @aliases = ["interpolate"]

  constructor: ->
    super
    @log.level = gg.util.Log.DEBUG


  defaults: ->
    group: "1"
    y0: 0
    x0: 'x'
    x1: 'x'

  # pts requires the schema
  #   x: x value
  #   y: height of the layer
  #   y0: (optional) baseline for the layer. only y0 of firstlayer is kept
  inputSchema: -> ['x', 'y']

  # x: x position, may have been interpolated
  # y: height of the layer
  # y0: position of layer's base
  # y1: position of layer's ceiling
  # group: layer's group key
  outputSchema: (table, env) ->
    gg.data.Schema.fromSpec
      group: table.schema.typeObj "group"
      x: table.schema.type 'x'
      y: table.schema.type 'y'
      y0: table.schema.type 'y'
      y1: table.schema.type 'y'
    table.schema.clone()


  #
  # @param xs sorted list of x values
  # @param pts list of {x:, y:} sorted on 'x'
  # @return array of {x:, y:} where y values are either
  #         1) original (if it existed) or
  #         2) linearly interpolated
  @interpolate: (xs, pts) ->
    if pts.length == 0
      return pts

    minx = _.first(pts).x
    maxx = _.last(pts).x
    ptsidx = 0
    ret = []
    for x, idx in xs
      if x < minx or x > maxx
        ret.push {x:x, y:0}
        continue
      while ptsidx+1 <= pts.length and pts[ptsidx].x < x
        ptsidx += 1
      if x is pts[ptsidx].x
        ret.push {x:x, y: pts[ptsidx].y}
      else
        prev = pts[ptsidx-1]
        cur = pts[ptsidx]
        perc = (x-prev.x) / (cur.x - prev.x)
        y = perc * (cur.y - prev.y) + prev.y
        ret.push {x:x, y:y}
    ret




