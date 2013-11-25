#<< gg/pos/position
#<< gg/pos/interpolate

#
# Stacks points that have the same x values.
#
# If stacking lines, may want to run gg.pos.XXX beforehand, so that
# the lines all have the same number of points and the x values are aligned.
#
class gg.pos.Stack extends gg.core.XForm
  @ggpackage = "gg.pos.Stack"
  @aliases = ["stack", "stacked"]


  parseSpec: ->
    super
    @params.put 'keys', ['facet-x', 'facet-y', 'layer']
    @params.put "padding", _.findGoodAttr @spec, ['pad', 'padding'], 0.05


  defaults: ->
    y0: 0
    y1: 'y'
    x0: 'x'
    x1: 'x'

  # pts requires the schema
  #   x: x value
  #   y: height of the group
  #   y0: (optional) baseline for the group. only y0 of firstlayer is kept
  inputSchema: -> ['x', 'y']

  # x: x position, may have been interpolated
  # y: natural y position.  y0 <= y <= y1
  # y0: position of layer's base
  # y1: position of layer's ceiling
  # group: layer's group key
  outputSchema: (pairtable) ->
    pairtable.leftSchema().clone()

  baselines: (table) ->
    # collect sorted list of x coords
    baselines = {}  # y0 values
    xs = table.all 'x'
    if table.has 'y0'
      y0s = table.all 'y0'
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
  compute: (pairtable, params) ->
    table = pairtable.left()
    [baselines, xs] = @baselines table

    layers = []
    groups = table.partition("group").all('table')
    console.log(groups)
    values = (group, groupidx) ->
      x2row = {}
      group.each (row) ->
        x2row[row.get 'x'] = {
          x: row.get 'x'
          y: row.get('y1') - (row.get('y0') or 0)
          y0: 0
        }

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
      group.each (row) ->
        x2row[row.get 'x'] = row.clone()

      _.each layer, (pos) ->
        x = pos.x
        if x of x2row
          row = x2row[x]
          row.set 'y0', pos.y0 + (baselines[x] or 0)
          row.set 'y1', row.get('y0') + pos.y
          row.set 'y', row.get('y1')
          if row.has 'x1'
            row.set 'x1', (row.get('x1')-row.get('x')+x)
          if row.has 'x0'
            row.set 'x0', (row.get('x0')-row.get('x')+x)
          row.set 'x', x
          newrows.push row

    schema = params.get('outputSchema') pairtable, params
    table = data.Table.fromArray newrows, schema
    gg.wf.Stdout.print table, null, 5, @log
    pairtable.left table
    pairtable
