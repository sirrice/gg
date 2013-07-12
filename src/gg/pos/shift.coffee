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

  compute: (data, params) ->
    map =
      x: (v) => v + params.get('xShift')
      y: (v) => v + params.get('yShift')
    data.table.map map
    data


