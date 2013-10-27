#<< gg/coord/coord

# The identity coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
class gg.coord.Identity extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Identity"
  @aliases = ["identity"]

  compute: (pt, params) ->
    table = pt.getTable()
    md = pt.getMD()
    schema = table.schema
    scales = md.get 0, 'scales'
    ytype = gg.data.Schema.unknown
    ytype = schema.type('y') if schema.has 'y'
    yscale = scales.get 'y', ytype

    origscale = yscale.clone()
    yRange = origscale.range()
    yRange = [yRange[1], yRange[0]]
    yscale.range yRange
    transform = (v) -> yscale.scale origscale.invert v

    @log origscale.toString()
    @log yscale.toString()
    @log "test transform: 500 -> #{origscale.invert 500} -> #{transform 500}"


    yaess = _.filter gg.scale.Scale.ys, (aes) -> schema.has aes
    mapping = _.map yaess, (col) -> [col, transform, gg.data.Schema.numeric]
    table = gg.data.Transform.mapCols pt.getTable(), mapping

    new gg.data.PairTable table, md

