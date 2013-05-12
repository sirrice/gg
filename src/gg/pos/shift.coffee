#<< gg/pos/position


class gg.pos.Shift extends gg.pos.Position
  @aliases = ["shift"]

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    @xShift = _.findGood [@spec.x, 10]
    @yShift = _.findGood [@spec.y, 10]
    super

  compute: (table, env) ->
    scale = Math.random()
    map =
      x: (v) => v + @xShift
      y: (v) => v * scale
    table.map map
    table


