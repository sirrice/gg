#<< gg/pos/position


class gg.pos.Shift extends gg.core.XForm
  @ggpackage = "gg.pos.Shift"
  @aliases = ["shift"]

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    super
    @params.putAll
      xShift: _.findGood [@spec.x, @spec.amount, 10]
      yShift: _.findGood [@spec.y, @spec.amount, 10]

  compute: (pairtable, params) ->
    map = [
      {alias: 'x', f: (v) -> v + params.get('xShift')}
      {alias: 'y', f: (v) -> v + params.get('yShift')}
    ]
    table = pairtable.left().mapCols map
    pairtable.left table
    pairtable
