#<< gg/coord/coord
#


class gg.coord.YFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.YFlip"
  @aliases = ["yflip"]

  compute: (data) ->
    @log "map: noop"
    data

class gg.coord.XFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.XFlip"
  @aliases = ["xflip"]

  compute: (data, params) ->
    table = data.getTable()
    scales = @scales data, params

    inverted = scales.invert table, gg.scale.Scale.xys
    xtype = ytype = gg.data.Schema.unknown
    xtype = table.schema.type('x') if table.has 'x'
    ytype = table.schema.type('y') if table.has 'y'

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

    if table.has('x0') and table.has('x1')
      table = gg.data.Transform.transform table, [
        ['x0', ((row) -> Math.min(row.get('x0'), row.get('x1'))), gg.data.Schema.numeric]
        ['x1', ((row) -> Math.max(row.get('x0'), row.get('x1'))), gg.data.Schema.numeric]
      ]

    new gg.data.PairTable table, data.getMD() 



class gg.coord.Flip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Flip"
  @aliases = ["flip", 'xyflip']

  compute: (data, params) ->
    table = data.getTable()
    md = data.getMD()
    scales = @scales data, params

    inverted = scales.invert table, gg.scale.Scale.xs

    type = table.schema.type 'x'
    xscale = scales.scale 'x', type
    xRange = xscale.range()
    xscale.range [xRange[1], xRange[0]]
    @log "map: xrange: #{xRange}"

    table = scales.apply inverted, gg.scale.Scale.xs

    if table.has('x0') and table.has('x1')
      table = gg.data.Transform.transform table, [
        ['x0', ((row) -> Math.min(row.get('x0'), row.get('x1'))), gg.data.Schema.numeric]
        ['x1', ((row) -> Math.max(row.get('x0'), row.get('x1'))), gg.data.Schema.numeric]
      ]

    new gg.data.PairTable table, md



