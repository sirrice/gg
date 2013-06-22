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


  # steps
  # 1) compute all X values
  # 2) compute y0 baseline for the layers,
  compute: (table, env, params) ->
    @log.warn "nrows: #{table.nrows()}\tschema: #{table.colNames()}"
    @log table.get(0).raw()

    inArray = table.schema.inArray 'x'
    arrKey = table.schema.attrToKeys['x']

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



    groups = table.split "group"
    layers = []
    # create copies for each group
    _.map groups, (group) =>
      if inArray
        x2row = {}
        _.each group.table.rows, (row) ->
          row.flatten(null, true).each (subrow) ->
            raw = subrow.clone().raw()
            x2row[raw.x] = raw
      else
        x2row = _.list2map group.table.rows, (row) ->
          raw = row.raw()
          [raw.x, raw]

      rows = _.values x2row
      rows.sort (a,b) -> a.x - b.x
      _.each rows, (row) -> row.y -= row.y0 or 0
      # if x,y values are in an array, then stacking should be interpolated
      if inArray
        rows = gg.pos.Interpolate.interpolate xs, rows
      layers.push rows

    stack = d3.layout.stack()
    # stack.offset("zero") # set stacking offset algorithm
    stackedLayers = stack(layers)
    @log "stacked #{stackedLayers.length} layers"

    schema = params.get('outputSchema') table, env, params
    rettable = new gg.data.RowTable schema

    _.times groups.length, (idx) =>
      group = groups[idx]
      layer = stackedLayers[idx]
      x2row = _.list2map group.table.rows, (row) -> [row.x, row]

      rows = layer.map (row) ->
        #row = new gg.data.Row row
        x = row.x
        row = _.extend(_.clone(x2row[x]), row) if x of x2row
        #x = row.get 'x'
        #row = x2row[x].clone().merge row if x of x2row
        row.y0 += baselines[x] or 0
        row.y1 = row.y0 + row.y
        #row.set 'y0', row.get('y0')+(baselines[x] or 0)
        #row.set 'y1', row.get('y0')+row.get('y')
        row

      if inArray
        rowData = {group: group.key}
        rowData[arrKey] =  _.map(rows, (row) ->
          raw = row
          delete raw['group']
          raw
        )
        rettable.addRow rowData
      else
        rettable.addRows rows

    @log "npts/row:  #{table.nrows()}"
    @log "nxs:       #{xs.length}"
    @log "nlayers:   #{layers.length}"

    gg.wf.Stdout.print rettable, null, 5, @log
    rettable


