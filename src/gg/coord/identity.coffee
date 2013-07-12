#<< gg/coord/coord

# The identity coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
class gg.coord.Identity extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Identity"
  @aliases = ["identity"]

  map: (data, params) ->
    [table, env] = [data.table, data.env]
    schema = table.schema
    scales = @scales data, params
    ytype = gg.data.Schema.unknown
    ytype = table.schema.type('y') if table.contains 'y'
    yscale = scales.get 'y', ytype


    origscale = yscale.clone()
    yRange = origscale.range()
    yRange = [yRange[1], yRange[0]]
    yscale.range yRange
    transform = (v) -> yscale.scale origscale.invert v

    @log origscale.toString()
    @log yscale.toString()
    @log "test transform: 500 -> #{origscale.invert 500} -> #{transform 500}"


    yaess = _.filter gg.scale.Scale.ys, (aes) -> table.contains aes
    table.each (row) ->
      _.each yaess, (aes) ->
        vals = row.get aes
        if _.isArray vals
          row.set aes, _.map(vals, transform)
        else
          row.set aes, transform(vals)

    gg.wf.Stdout.print table, ['x', 'y'], 5, @log
    data.table = table
    data

