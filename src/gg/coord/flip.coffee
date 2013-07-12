#<< gg/coord/coord
#


class gg.coord.YFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.YFlip"
  @aliases = ["yflip"]

  map: (data) ->
    @log "map: noop"
    data

class gg.coord.XFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.XFlip"
  @aliases = ["xflip"]

  map: (data, params) ->
    table = data.table
    env = data.env
    scales = @scales data, params

    inverted = scales.invert table, gg.scale.Scale.xys
    xtype = ytype = gg.data.Schema.unknown
    xtype = table.schema.type('x') if table.contains 'x'
    ytype = table.schema.type('y') if table.contains 'y'

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

    data.table = table
    data



class gg.coord.Flip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Flip"
  @aliases = ["flip", 'xyflip']

  map: (data, params) ->
    table = data.table
    env = data.env
    scales = @scales data, params
    inverted = scales.invert table, gg.scale.Scale.xs
    type = table.schema.type 'x'
    xscale = scales.scale 'x', type

    xRange = xscale.range()
    xscale.range [xRange[1], xRange[0]]

    @log "map: xrange: #{xRange}"

    table = scales.apply inverted, gg.scale.Scale.xs

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    data.table = table
    data



