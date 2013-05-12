#<< gg/coord/coord

# The identity coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
class gg.coord.Identity extends gg.coord.Coordinate
  @aliases = ["identity"]

  map: (table, env) ->
    schema = table.schema
    scales = @scales table, env
    posMapping = {}
    _.each gg.scale.Scale.ys, (y) ->
      posMapping[y] = 'y' if table.contains y

    console.log "gg.IdentityCoordinate\t#{_.keys(posMapping)}"
    inverted = scales.invert table, _.keys(posMapping), posMapping
    console.log "gg.IdentityCoordinate y0inverted: #{inverted.getColumn("y0")[0...10]}" if inverted.schema.contains 'y0'
    console.log inverted.raw()


    # get and flip the y range
    # XXX: we need a better managed way to get the scale
    #      for a given aesthetic!
    #      Foo.getColumnFromAes('y') --> "y"
    if table.contains 'y'
      yScale = scales.scale 'y', table.schema.type('y')# gg.Schema.numeric
    else
      yScale = scales.scale 'y', gg.data.Schema.unknown
    yRange = yScale.range()
    yRange = [yRange[1], yRange[0]]
    yScale.range(yRange)
    console.log "gg.IdentityCoordinate yrange: #{yRange}"


    table = scales.apply inverted, gg.scale.Scale.ys, posMapping
    table.schema = schema

    console.log "gg.IdentityCoordinate y0applied: #{table.getColumn("y0")[0...10]}" if table.contains "y0"
    console.log table.raw()
    table


