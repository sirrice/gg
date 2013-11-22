#<< gg/coord/coord

# The identity coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
class gg.coord.Identity extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Identity"
  @aliases = ["identity"]

  compute: (pt, params) ->
    table = pt.left()
    md = pt.right()
    schema = table.schema
    scales = md.any 'scales'
    yscale = scales.get 'y'

    origscale = yscale.clone()
    yRange = origscale.range()
    yRange = [yRange[1], yRange[0]]
    yscale.range yRange
    transform = (v) -> yscale.scale origscale.invert v

    @log origscale.toString()
    @log yscale.toString()
    @log "test transform: 500 -> #{origscale.invert 500} -> #{transform 500}"


    yaess = _.filter gg.scale.Scale.ys, (aes) -> schema.has aes
    mapping = _.map yaess, (col) -> {
      alias: col,
      f: transform
      type: data.Schema.numeric
      cols: col
    }
    table = table.project mapping, yes
    pt.left table
    pt

