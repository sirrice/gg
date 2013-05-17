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

    @log "posMapping:\t#{_.keys(posMapping)}"
    inverted = scales.invert table, _.keys(posMapping), posMapping
    @log inverted.raw()[0..5]


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
    @log "yrange: #{yRange}"


    table = scales.apply inverted, gg.scale.Scale.ys, posMapping
    table.schema = schema

    @log JSON.stringify(table.raw()[0..5])
    table


