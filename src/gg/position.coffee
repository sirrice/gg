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

    console.log "Position.fromSpec #{type.name} from #{JSON.stringify spec}"

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
    xRange = scales.scale("x").range()
    yRange = scales.scale("y").range()
    xScale = (xRange[1] - xRange[0]) * @xScale
    yScale = (yRange[1] - yRange[0]) * @yScale

    map =
      x: (v) -> v + (0.5 - Math.random()) * xScale
      y: (v) -> v + (0.5 - Math.random()) * yScale
    table.map map
    table



class gg.StackPosition extends gg.Position
  @aliases = ["stack", "stacked"]

  inputSchema: -> ['group', 'pts']
  outputSchema: ->
    ['group', 'x', 'y0', 'y1']

  parseSpec: ->
    super

  #
  # @param xs sorted list of x values
  # @param pts array of gg.rows sorted on 'x', has 'y' values
  # @return array of {x:, y:} where y values are linearly interpolated
  # TODO: use d3 library
  @interpolate: (xs, pts) ->
    if pts.length == 0
      return pts

    minx = _.first(pts).x
    maxx = _.last(pts).x
    ptsidx = 0
    ret = []
    for x, idx in xs
      if x < minx or x > maxx
        ret.push {x:x, y:null}
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


  compute: (table, env) ->
    # collect sorted list of x coords
    xscache = {}
    xs = []
    table.each (row) ->
      pts = row.get 'pts'
      _.each pts, (pt) ->
        x = pt.x
        xs.push x unless x of xscache
        xscache[x] = yes
    xs.sort((a,b)->a-b)

    table.each (row) ->
      pts = row.get 'pts'
      newpts = pts.sort((r1, r2) -> r1.x - r2.x)
      newpts = gg.StackPosition.interpolate xs, newpts
      row.set 'pts', newpts

    # now stack them up!
    _.each xs, (x, idx) ->
      sum = 0
      table.each (row) ->
        pts = row.get('pts')
        presum = sum
        sum += pts[idx].y if pts[idx].y?
        pts[idx].y0 = presum
        pts[idx].y1 = sum


    console.log "computed area: #{table.getColumn('pts')[0]}"

    table

