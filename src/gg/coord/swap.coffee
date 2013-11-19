#<< gg/coord/coord

# The swap coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
#
# TODO: doesn't work for boxplot/rect yet
class gg.coord.Swap extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Swap"
  @aliases = ["swap"]

  compute: (pt, params) ->
    table = pt.left()
    scales = @scales pt, params
    xtype = ytype = data.Schema.unknown
    xtype = table.schema.type('x') if table.has 'x'
    ytype = table.schema.type('y') if table.has 'y'
    xScale = scales.scale 'x', xtype
    xRange = xScale.range()
    yScale = scales.scale 'y', ytype
    yRange = yScale.range()



    # invert to original domain
    # swap table xs for ys
    # swap scale x for y
    # reapply scales

    inverted = scales.invert table, gg.scale.Scale.xys
    xcols = _.o2map gg.scale.Scale.xs, (x) ->
      if inverted.has x
        [x, inverted.all x]
    ycols = _.o2map gg.scale.Scale.ys, (y) ->
      if inverted.has y
        [y, inverted.all y]

    for x, colData of xcols
      if x.search('^x') >= 0
        newcol = "y#{x.substr 1}"
        inverted = inverted.setCol newcol, colData, xtype, yes

    for y, colData of ycols
      if y.search('^y') >= 0
        newcol = "x#{y.substr 1}"
        inverted = inverted.setCol newcol, colData, ytype, yes

    # now swap the x and y scales
    xScale.range [yRange[1], yRange[0]]
    yScale.range xRange
    xScale.aes = 'y'
    yScale.aes = 'x'
    scales.set xScale
    scales.set yScale

    table = scales.apply inverted, gg.scale.Scale.xys
    pt.left table
    pt 
