#<< gg/coord/coord
#


class gg.coord.YFlip extends gg.coord.Coordinate
  @aliases = ["yflip"]

  map: (table, env) ->
    @log "map: noop"
    table

class gg.coord.XFlip extends gg.coord.Coordinate
  @aliases = ["xflip"]

  map: (table, env) ->
    scales = @scales table, env
    aessTypes = {}
    _.each gg.scale.Scale.xys, (xy) -> aessTypes[xy] = gg.data.Schema.numeric
    inverted = scales.invert table, gg.scale.Scale.xys
    xtype = if table.contains 'x' then table.schema.type 'x' else gg.data.Schema.unknown
    ytype = if table.contains 'y' then table.schema.type 'y' else gg.data.Schema.unknown

    # flip the x range
    xScale = scales.scale 'x', xtype
    xRange = xScale.range()
    xRange = [xRange[1], xRange[0]]
    xScale.range xRange

    # flip the y range
    yScale = scales.scale 'y', ytype
    yRange = yScale.range()
    yRange = [yRange[1], yRange[0]]
    yScale.range yRange

    @log "map: xrange: #{xRange}\tyrange: #{yRange}"

    table = scales.apply inverted, gg.scale.Scale.xys

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table



class gg.coord.Flip extends gg.coord.Coordinate
  @aliases = ["flip", 'xyflip']

  map: (table, env) ->
    scales = @scales table, env
    inverted = scales.invert table, gg.scale.Scale.xs
    type = table.schema.type 'x'

    xRange = scales.scale('x', type).range()
    xRange = [xRange[1], xRange[0]]
    scales.scale('x', type).range(xRange)

    @log "map: xrange: #{xRange}"

    table = scales.apply inverted, gg.scale.Scale.xs

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table



