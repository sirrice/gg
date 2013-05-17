#<< gg/stat/stat


class gg.stat.LoessStat extends gg.stat.Stat
  @aliases = ['loess', 'smooth']


  parseSpec: ->
    super

  inputSchema: (table, env, node) -> ['x', 'y']
  outputSchema: (table, env, node) ->
    gg.data.Schema.fromSpec
      x: gg.data.Schema.numeric
      y: gg.data.Schema.numeric

  # The loess function expects an xs and ys array where
  # 1) every value is a finite number
  # 2) xs is monotonically increasing
  compute: (table, env, node) ->
    isValid = (v) -> not(
      _.isNaN(v) or _.isUndefined(v) or _.isNull(v)
    )
    xs = table.getColumn('x')
    ys = table.getColumn('y')
    xys = _.zip(xs, ys)
    xys = xys.filter (xy) -> isValid(xy[0]) and isValid(xy[1])
    xys.sort (xy1, xy2) -> xy1[0] - xy2[0]
    xs = xys.map (xy) -> xy[0]
    ys = xys.map (xy) -> xy[1]
    loessfunc = science.stats.loess()

    smoothys = loessfunc(xs, ys)
    rows = []
    _.times xs.length, (idx) ->
      rows.push
        x: xs[idx]
        y: smoothys[idx]

    @log "compute: xs: #{JSON.stringify xs.slice(0,6)}"
    @log "compute: ys: #{JSON.stringify ys.slice(0,6)}"
    @log "compute: smoothys: #{JSON.stringify smoothys.slice(0,6)}"

    new gg.data.RowTable @outputSchema(), rows
