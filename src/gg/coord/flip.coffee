#<< gg/coord/coord
#


class gg.coord.YFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.YFlip"
  @aliases = ["yflip"]

  compute: (pt) ->
    @log "map: noop"
    pt

class gg.coord.XFlip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.XFlip"
  @aliases = ["xflip"]

  compute: (pt, params) ->
    table = pt.left()
    scales = @scales pt, params

    inverted = scales.invert table, gg.scale.Scale.xys
    xtype = ytype = data.Schema.unknown
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
      table = table.project [
        {
          alias: 'x0'
          f: Math.min
          type: data.Schema.numeric
          cols: ['x0', 'x1']
        }
        {
          alias: 'x1'
          f: Math.max
          type: data.Schema.numeric
          cols: ['x0', 'x1']
        }
      ], yes

    pt.left table
    pt



class gg.coord.Flip extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Flip"
  @aliases = ["flip", 'xyflip']

  compute: (pt, params) ->
    table = pt.left()
    md = pt.right()
    scales = @scales pt, params

    inverted = scales.invert table, gg.scale.Scale.xs

    type = table.schema.type 'x'
    xscale = scales.scale 'x', type
    xRange = xscale.range()
    xscale.range [xRange[1], xRange[0]]
    @log "map: xrange: #{xRange}"

    table = scales.apply inverted, gg.scale.Scale.xs

    if table.has('x0') and table.has('x1')
      table = table.project [
        {
          alias: 'x0'
          f: Math.min
          type: data.Schema.numeric
          cols: ['x0', 'x1']
        }
        {
          alias: 'x1'
          f: Math.max
          type: data.Schema.numeric
          cols: ['x0', 'x1']
        }
      ], yes

    pt.left table
    pt 

