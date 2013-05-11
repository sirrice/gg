#<< gg/xform

class gg.Coordinate extends gg.XForm
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.IdentityCoordinate,
      gg.YFlipCoordinate,
      gg.XFlipCoordinate,
      gg.FlipCoordinate
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = gg.Coordinate.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.IdentityCoordinate

    console.log "Coordinate.fromSpec: klass #{klass.name} from spec #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

  compute: (table, env, node) -> @map table, env, node

  map: (table, env) -> throw Error("#{@name}.map() not implemented")


class gg.IdentityCoordinate extends gg.Coordinate
  @aliases = ["identity"]

  map: (table, env) ->
    schema = table.schema
    scales = @scales table, env
    posMapping = {}
    _.each gg.Scale.ys, (y) ->
      posMapping[y] = 'y' if table.contains y
    console.log "gg.IdentityCoordinate\t#{_.keys(posMapping)}"
    inverted = scales.invert table, _.keys(posMapping), posMapping
    console.log "gg.IdentityCoordinate y0inverted: #{inverted.getColumn("y0")[0...10]}" if inverted.schema.contains 'y0'
    console.log inverted.raw()
    yScale = scales.scale 'y', table.schema.type('y')# gg.Schema.numeric
    yRange = yScale.range()
    console.log "gg.IdentityCoordinate yrange: #{yRange}"
    yRange = [yRange[1], yRange[0]]
    yScale.range(yRange)
    table = scales.apply inverted, gg.Scale.ys, posMapping
    console.log "gg.IdentityCoordinate y0applied: #{table.getColumn("y0")[0...10]}"
    console.log table.raw()
    table.schema = schema
    table

class gg.YFlipCoordinate extends gg.Coordinate
  @aliases = ["yflip"]

  map: (table, env) ->
    @log "map: noop"
    table

class gg.XFlipCoordinate extends gg.Coordinate
  @aliases = ["xflip"]

  map: (table, env) ->
    console.log "gg.XFlipCoordinate"
    scales = @scales table, env
    aessTypes = {}
    _.each gg.Scale.xys, (xy) -> aessTypes[xy] = gg.Schema.numeric
    inverted = scales.invert table, gg.Scale.xys
    xtype = table.schema.type 'x'
    ytype = table.schema.type 'y'

    xScale = scales.scale 'x', xtype
    xRange = xScale.range()
    xRange = [xRange[1], xRange[0]]
    xScale.range xRange

    yScale = scales.scale 'y', ytype
    yRange = yScale.range()
    yRange = [yRange[1], yRange[0]]
    yScale.range yRange

    @log "map: xrange: #{xRange}\tyrange: #{yRange}"

    table = scales.apply inverted, gg.Scale.xys

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table



class gg.FlipCoordinate extends gg.Coordinate
  @aliases = ["flip", 'xyflip']

  map: (table, env) ->
    scales = @scales table, env
    inverted = scales.invert table, gg.Scale.xs
    type = table.schema.type 'x'

    xRange = scales.scale('x', type).range()
    xRange = [xRange[1], xRange[0]]
    scales.scale('x', type).range(xRange)

    @log "map: xrange: #{xRange}"

    table = scales.apply inverted, gg.Scale.xs

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table



