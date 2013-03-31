#<< gg/xform

class gg.Position extends gg.XForm
  constructor: (@layer, @spec={}) ->
    super @layer.g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.IdentityPosition,
      gg.ShiftPosition,
      gg.JitterPosition
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

    ret = new klass layer, spec
    ret

class gg.IdentityPosition extends gg.Position
  @aliases = ["identity"]


class gg.ShiftPosition extends gg.Position
  @aliases = ["shift"]

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



