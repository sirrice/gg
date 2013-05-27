#<< gg/stat/stat


class gg.stat.LoessStat extends gg.stat.Stat
  @aliases = ['loess', 'smooth']


  parseSpec: ->
    @bandwidth = _.findGoodAttr @spec, ["bandwidth", "band", "bw"], .3
    @acc = _.findGoodAttr @spec, ["accuracy", "acc", "ac"], 1e-12
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
    @log "nrows: #{table.nrows()}"
    @log "contains x,y: #{table.contains 'x'}, #{table.contains 'y'}"
    xs = table.getColumn('x')
    ys = table.getColumn('y')
    @log "nxs: #{xs.length}\tnys: #{ys.length}"
    # remove invald entries
    xys = _.zip(xs, ys)
    xys = xys.filter (xy) -> _.isValid(xy[0]) and _.isValid(xy[1])
    xys.sort (xy1, xy2) -> xy1[0] - xy2[0]
    xs = xys.map (xy) -> xy[0]
    ys = xys.map (xy) -> xy[1]

    loessfunc = science.stats.loess()
    bandwidth = Math.max @bandwidth, 3.0/xs.length
    loessfunc.bandwidth bandwidth
    loessfunc.accuracy @acc
    @log.warn "bw: #{bandwidth}\tacc: #{@acc}"

    smoothys = loessfunc(xs, ys)
    rows = []
    _.times xs.length, (idx) ->
      # sometimes it interpolates to NaN values
      if _.isValid smoothys[idx]
        rows.push
          x: xs[idx]
          y: smoothys[idx]

    @log "compute: xs: #{JSON.stringify xs.slice(0,6)}"
    @log "compute: ys: #{JSON.stringify ys.slice(0,6)}"
    @log "compute: smoothys: #{JSON.stringify smoothys.slice(0,6)}"

    new gg.data.RowTable @outputSchema(), rows
