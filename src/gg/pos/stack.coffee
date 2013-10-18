#<< gg/pos/position
#<< gg/pos/interpolate

#
# Stacks points that have the same x values.
#
# If stacking lines, may want to run gg.pos.XXX beforehand, so that
# the lines all have the same number of points and the x values are aligned.
#
class gg.pos.Stack extends gg.pos.Position
  @ggpackage = "gg.pos.Stack"
  @aliases = ["stack", "stacked"]

  addDefaults: ->
    group: {}
    y0: 0
    y1: 'y'
    x0: 'x'
    x1: 'x'

  # pts requires the schema
  #   x: x value
  #   y: height of the layer
  #   y0: (optional) baseline for the layer. only y0 of firstlayer is kept
  inputSchema: -> ['x', 'y']

  # x: x position, may have been interpolated
  # y: natural y position.  y0 <= y <= y1
  # y0: position of layer's base
  # y1: position of layer's ceiling
  # group: layer's group key
  outputSchema: (pairtable) ->
    schema = pairtable.tableSchema()
    gg.data.Schema.fromJSON
      group: schema.type "group"
      x: schema.type 'x'
      y: schema.type 'y'
      y0: schema.type 'y'
      y1: schema.type 'y'
    schema.clone()

  baselines: (table) ->
    # collect sorted list of x coords
    baselines = {}  # y0 values
    xs = table.getColumn 'x'
    if table.has 'y0'
      y0s = table.getColumn 'y0'
      _.times xs.length, (idx) -> baselines[xs[idx]] = y0s[idx]
      @log "y0s: #{y0s[0..10]}"
    xs = _.uniq xs
    xs.sort (a,b) -> a-b
    @log "nxs: #{xs.length}"
    [baselines, xs]


  # steps
  # 1) compute all X values
  # 2) compute y0 baseline for the layers,
  #
  # Unfortunately the data model isn't very good so we need to special case
  # when the x,y values are nested in arrays, or in the top level of the table
  #
  # e.g., if the schema is:
  #
  # 1) { x, y } or
  # 2) { points: { x, y } }
  #
  compute: (pairtable, params) ->
    table = pairtable.getTable()
    [baselines, xs] = @baselines table

    layers = []
    groups = table.partition "group"
    values = (group, groupidx) ->
      x2row = {}
      group.each (row) ->
        x2row[row.get('x')] =
          x: row.get 'x'
          y: row.get('y1') - (row.get('y0') or 0)
          y0: 0

      rows = _.map xs, (x) ->
        if x of x2row then x2row[x] else {x:x, y:0, y0:0}
      rows


    layers = _.map groups, values
    stack = d3.layout.stack()
    stackedLayers = stack(layers)


    newrows = []
    _.each groups, (group, idx) ->
      layer = stackedLayers[idx]
      x2row = {}
      group.each (row) -> x2row[row.get('x')] = row

      _.each layer, (pos) ->
        x = pos.x
        if x of x2row
          row = x2row[x]
          row.set 'y0', pos.y0 + (baselines[x] or 0)
          row.set 'y1', row.get('y0') + pos.y
          row.set 'y', row.get('y1')
          newrows.push row

    schema = params.get('outputSchema') pairtable, params
    table = gg.data.Table.fromArray newrows
    gg.wf.Stdout.print table, null, 5, @log
    new gg.data.PairTable table, pairtable.getMD()

