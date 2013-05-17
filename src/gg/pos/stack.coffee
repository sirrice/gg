#<< gg/pos/position
#

class gg.pos.Interpolate extends gg.pos.Position
  @aliases = ["interpolate"]


#
# Stacks points that have the same x values.
#
# If stacking lines, may want to run gg.pos.XXX beforehand, so that
# the lines all have the same number of points and the x values are aligned.
#
class gg.pos.Stack extends gg.pos.Position
  @aliases = ["stack", "stacked"]

  constructor: ->
    super
    @log.level = gg.util.Log.DEBUG


  addDefaults: ->
    group: "1"
    y0: 0
    x0: 'x'
    x1: 'x'

  # pts requires the schema
  #   x: x value
  #   y: height of the layer
  #   y0: (optional) baseline for the layer. only y0 of firstlayer is kept
  inputSchema: -> ['x', 'y']

  # x: x position, may have been interpolated
  # y: height of the layer
  # y0: position of layer's base
  # y1: position of layer's ceiling
  # group: layer's group key
  outputSchema: ->
    ['group', 'x', 'y', 'y0', 'y1']

  parseSpec: ->
    super

  #
  # @param xs sorted list of x values
  # @param pts array of gg.rows sorted on 'x', has 'y' values
  # @return array of {x:, y:, y0:} where
  #         y values are linearly interpolated
  @interpolate: (xs, pts) ->
    if pts.length == 0
      return pts

    minx = _.first(pts).x
    maxx = _.last(pts).x
    ptsidx = 0
    ret = []
    for x, idx in xs
      if x < minx or x > maxx
        ret.push {x:x, y:0}
        continue
      while ptsidx+1 <= pts.length and pts[ptsidx].x < x
        ptsidx += 1
      if x is pts[ptsidx].x
        ret.push {x:x, y: pts[ptsidx].y}
      else
        prev = pts[ptsidx-1]
        cur = pts[ptsidx]
        perc = (x-prev.x) / (cur.x - prev.x)
        y = perc * (cur.y - prev.y) + prev.y
        ret.push {x:x, y:y}
    ret


  # steps
  # 1) compute all X values
  # 2) compute y0 baseline for the layers,
  compute: (table, env) ->
    @log.warn "nrows: #{table.nrows()}\tschema: #{table.colNames()}"

    # collect sorted list of x coords
    baselines = {}  # y0 values
    xs = table.getColumn('x')
    if table.contains "y0"
      y0s = table.getColumn "y0"
      _.times xs.length, (idx) -> baselines[xs[idx]] = y0s[idx]
    xs = _.uniq _.compact xs
    xs.sort((a,b)->a-b)
    @log "nxs: #{xs.length}"


    groups = table.split "group"
    layers = []
    # create copies for each group
    _.map groups, (group) =>
      x2row = _.list2map group.table.rows, ((row) -> [row.get('x'), row.raw()])
      rows = _.map xs, (x) =>
        if x of x2row
          x2row[x]
        else
          x: x
          y: 0
          y0: 0
          y1: 0

      layers.push rows

    stack = d3.layout.stack()
    # stack.offset("zero") # set stacking offset algorithm
    stackedLayers = stack(layers)
    @log "stacked the layers"

    rettable = new gg.data.RowTable table.schema
    _.times groups.length, (idx) =>
      group = groups[idx]
      layer = stackedLayers[idx]
      @log layer
      x2row = _.list2map group.table.rows, (row) -> [row.x, row]

      rettable.addRows layer.map (row) ->
        row = new gg.data.Row row, table.schema
        x = row.get 'x'
        row = x2row[x].clone().merge row if x of x2row
        row.set 'y0', row.get('y0')+(baselines[x] or 0)
        row.set 'y1', row.get('y0')+row.get('y')
        row


    @log "npts/row:  #{table.nrows()}"
    @log "nxs:       #{xs.length}"
    @log "baselines: #{JSON.stringify baselines}"
    @log "nlayers:   #{layers.length}"

    return rettable


