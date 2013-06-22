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

  constructor: ->
    super
    @log.level = gg.util.Log.DEBUG


  addDefaults: ->
    group: "1"
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
  outputSchema: (table, env) ->
    gg.data.Schema.fromSpec
      group: table.schema.typeObj "group"
      x: table.schema.type 'x'
      y: table.schema.type 'y'
      y0: table.schema.type 'y'
      y1: table.schema.type 'y'
    table.schema.clone()

  parseSpec: ->
    super

  baselines: (table) ->
    # collect sorted list of x coords
    baselines = {}  # y0 values
    xs = table.getColumn('x')
    if table.contains "y0"
      y0s = table.getColumn "y0"
      _.times xs.length, (idx) -> baselines[xs[idx]] = y0s[idx]
    xs = _.uniq _.compact xs
    xs.sort((a,b)->a-b)
    @log "y0s: #{y0s[0..10]}"
    @log "nxs: #{xs.length}"
    [baselines, xs]

  computeInArray: (table, env, params) ->
    arrKey = table.schema.attrToKeys['x']
    [baselines, xs] = @baselines table
    groups = table.split "group"
    layers = []
    # create copies for each group

    values = (group) ->
      x2row = {}
      group.table.each (row) ->
        row.flatten(null, true).each (subrow) ->
          x2row[subrow.get('x')] =
            x: subrow.get('x')
            y: subrow.get('y1') - (subrow.get('y0') or 0)
            y0: 0

      rows = _.values x2row
      rows.sort (a,b) -> a.x - b.x
      # if x,y values are in an array, then stacking should be interpolated
      rows = gg.pos.Interpolate.interpolate xs, rows
      rows

    layers = _.map groups, values
    stack = d3.layout.stack()
    stackedLayers = stack(layers)

    schema = params.get('outputSchema') table, env, params
    rettable = new gg.data.RowTable schema

    _.times groups.length, (idx) =>
      group = groups[idx]
      layer = stackedLayers[idx]
      # create hash table for flattened rows in group.table
      x2row = {}
      group.table.each (row) ->
        for raw, idx in row.get(arrKey)
          x2row[raw.x] = raw

      console.log layer
      rows = layer.map (pos) ->
        x = pos.x
        if x of x2row
          row = x2row[x]
          row.y0 = pos.y0 + (baselines[x] or 0)
          row.y1 = row.y0 + pos.y
          row.y = row.y1
        else
          row = pos
          row.y0 += baselines[x] or 0
          row.y1 = row.y0 + row.y
        row

      rowData = group: group.key
      rowData[arrKey] =  _.map(rows, (row) ->
        raw = row
        delete raw['group']
        raw
      )
      rettable.addRow rowData

    rettable

  computeNormal: (table, env, params) ->
    [baselines, xs] = @baselines table

    groups = table.split "group"
    layers = []
    # create copies for each group

    values = (group) ->
      x2row = {}
      group.table.each (row) ->
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

    schema = params.get('outputSchema') table, env, params
    rettable = new gg.data.RowTable schema

    # XXX: rewrite so don't need to clone
    _.times groups.length, (idx) =>
      group = groups[idx]
      layer = stackedLayers[idx]
      x2row = {}
      group.table.each (row) -> x2row[row.get('x')] = row

      _.each layer, (pos) ->
        x = pos.x
        if x of x2row
          row = x2row[x]
          row.set 'y0', pos.y0 + (baselines[x] or 0)
          row.set 'y1', row.get('y0') + pos.y
          row.set 'y', row.get('y1')
          rettable.addRow row

    rettable


  # steps
  # 1) compute all X values
  # 2) compute y0 baseline for the layers,
  compute: (table, env, params) ->
    @log.warn "nrows: #{table.nrows()}\tschema: #{table.colNames()}"
    @log table.get(0).raw()

    inArray = table.schema.inArray 'x'
    if inArray
      rettable = @computeInArray table, env, params
    else
      rettable = @computeNormal table, env, params

    @log "input rows:   #{table.nrows()}"
    @log "output rows:  #{rettable.nrows()}"

    gg.wf.Stdout.print rettable, null, 5, @log
    rettable


