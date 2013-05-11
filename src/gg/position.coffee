#<< gg/xform

class gg.Position extends gg.XForm
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.IdentityPosition,
      gg.ShiftPosition,
      gg.JitterPosition,
      gg.StackPosition
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = gg.Position.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.IdentityPosition

    console.log "Position.fromSpec: klass #{klass.name} from spec #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

class gg.IdentityPosition extends gg.Position
  @aliases = ["identity"]


class gg.ShiftPosition extends gg.Position
  @aliases = ["shift"]

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    @xShift = findGood [@spec.x, 10]
    @yShift = findGood [@spec.y, 10]
    super

  compute: (table, env) ->
    scale = Math.random()
    map =
      x: (v) => v + @xShift
      y: (v) => v * scale
    table.map map
    table


class gg.JitterPosition extends gg.Position
  @aliases = "jitter"

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    @scale = findGood [@spec.scale, 0.2]
    @xScale = findGood [@spec.xScale, @spec.x, null]
    @yScale = findGood [@spec.yScale, @spec.y, null]
    if @xScale? or @yScale?
      @xScale = @xScale or 0
      @yScale = @yScale or 0
    else
      @xScale = @yScale = @scale
    super

  compute: (table, env) ->
    scales = @scales table, env
    schema = table.schema
    map = {}
    if schema.type('x') is gg.Schema.numeric
      xRange = scales.scale("x", gg.Schema.numeric).range()
      xScale = (xRange[1] - xRange[0]) * @xScale
      map['x'] = (v) -> v + (0.5 - Math.random()) * xScale
    if schema.type('y') is gg.Schema.numeric
      yRange = scales.scale("y", gg.Schema.numeric).range()
      yScale = (yRange[1] - yRange[0]) * @yScale
      map['y'] = (v) -> v + (0.5 - Math.random()) * yScale

    table.map map
    table



class gg.StackPosition extends gg.Position
  @aliases = ["stack", "stacked"]

  # pts requires the schema
  #   x: x value
  #   y: height of the layer
  #   y0: (optional) baseline for the layer. only y0 of firstlayer is kept
  inputSchema: -> ['group', 'pts']

  # x: x position, may have been interpolated
  # y: height of the layer
  # y0: position of layer's base
  # y1: position of layer's ceiling
  # group: layer's group key
  outputSchema: -> ['group', 'x', 'y', 'y0', 'y1']

  parseSpec: ->
    super

  #
  # @param xs sorted list of x values
  # @param pts array of gg.rows sorted on 'x', has 'y' values
  # @return array of {x:, y:, y0:} where
  #         y values are linearly interpolated
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


  # steps
  # 1) compute all X values
  # 2) compute y0 baseline for the layers,
  compute: (table, env) ->

    # collect sorted list of x coords
    xs = []
    npts = []
    baselines = {}  # y0 values
    table.each (row) ->
      pts = row.get 'pts'
      npts.push pts.length
      _.each pts, (pt) ->
        x = pt.x
        xs.push x unless x of baselines
        baselines[x] = pt.y0 if x not of baselines and pt.y0?
    xs.sort((a,b)->a-b)
    baselines = _.map xs, (x) -> baselines[x] or 0


    layers = []
    table.each (row) ->
      pts = row.get 'pts'
      newpts = pts.sort((r1, r2) -> r1.x - r2.x)
      newpts = gg.StackPosition.interpolate xs, newpts
      layers.push newpts

    console.log "gg.StackPosition: npts per row: #{npts}"
    console.log "gg.StackPosition: num xs:       #{xs.length}"
    console.log "gg.Stackposition: baselines: #{JSON.stringify baselines}"
    console.log "gg.StackPosition: num layers:   #{layers.length}"

    stack = d3.layout.stack()
    # stack.offset("zero") # set stacking offset algorithm
    stackedLayers = stack(layers)


    # update the table
    _.each stackedLayers, (layer, rowidx) ->
      layer = layer.filter (pt) -> pt.y?
      _.each layer, (pt, idx) ->
        pt.y0 = pt.y0 + baselines[idx]
        pt.y1 = pt.y + pt.y0
      table.get(rowidx).set('pts', layer)



    console.log "gg.StackPosition: nrows       : #{table.nrows()}"
    console.log "gg.StackPosition: final schema: #{table.colNames()}"

    ptsCol = if table.contains 'pts' then table.getColumn('pts')
    ptsCol = [] unless ptsCol?

    console.log "computed area(0): #{JSON.stringify ptsCol[0][0..10]}" if ptsCol.length > 0
    console.log "computed area(1): #{JSON.stringify ptsCol[1][0..10]}" if ptsCol.length > 1
    console.log "computed area(2): #{JSON.stringify ptsCol[2][0..10]}" if ptsCol.length > 2
    console.log "flattened: #{JSON.stringify table.get(0).flatten().raw()[0..10]}" if table.nrows() > 0
    console.log "flattened: #{JSON.stringify table.get(1).flatten().raw()[0..10]}" if table.nrows() > 1

    table

