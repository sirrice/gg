#<< gg/pos/position


class gg.pos.Shift extends gg.pos.Position
  @ggpackage = "gg.pos.Shift"
  @aliases = ["shift"]

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    super
    @params.putAll
      xShift: _.findGood [@spec.x, @spec.amount, 10]
      yShift: _.findGood [@spec.y, @spec.amount, 10]

  compute: (pairtable, params) ->
    map =
      x: (v) => v + params.get('xShift')
      y: (v) => v + params.get('yShift')
    table = pairtable.getTable()
    table = gg.data.Transform.mapCols table, map
    new gg.data.PairTable table, pairtable.getMD()


