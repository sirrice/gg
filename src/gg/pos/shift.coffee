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
    table = pairtable.left()
    xshift = params.get 'xShift'
    yshift = params.get 'yShift'
    xcols = _.filter gg.scale.Scale.xs, (col) -> table.has col
    ycols = _.filter gg.scale.Scale.ys, (col) -> table.has col
    map = []
    map = map.concat _.map(xcols, (col) ->
      {alias: col, f: (v) -> v + xshift}
    )
    map = map.concat _.map(ycols, (col) ->
      {alias: col, f: (v) -> v + yshift}
    )

    table = pairtable.left().project map, yes
    pairtable.left table
    pairtable
