#<< gg/stat/stat

science = require 'science'

class gg.stat.LoessStat extends gg.stat.Stat
  @ggpackage = "gg.stat.LoessStat"
  @aliases = ['loess', 'smooth']

  parseSpec: ->
    super
    @params.ensureAll
      bandwidth: [["band", "bw"], .3]
      acc: [["accuracy", "ac"], 1e-12]

  inputSchema: -> ['x', 'y']

  outputSchema: (data) ->
    gg.data.Schema.fromSpec
      x: gg.data.Schema.numeric
      y: gg.data.Schema.numeric

  schemaMapping: (data) ->
    x: 'x'
    y: 'y'

  # The loess function expects an xs and ys array where
  # 1) every value is a finite number
  # 2) xs is monotonically increasing
  compute: (data, params) ->
    table = data.table
    env = data.env
    if table.nrows() <= 1
      return data
    @log "nrows: #{table.nrows()}"
    @log "contains x,y: #{table.contains 'x'}, #{table.contains 'y'}"
    xs = table.getColumn('x')
    ys = table.getColumn('y')
    # remove invald entries
    xys = _.zip(xs, ys)
    xys = xys.filter (xy) -> _.isValid(xy[0]) and _.isValid(xy[1])
    xys.sort (xy1, xy2) -> xy1[0] - xy2[0]
    xs = xys.map (xy) -> xy[0]
    ys = xys.map (xy) -> xy[1]

    @log params
    @log "precompute: ys: #{JSON.stringify ys.slice(0,6)}"


    loessfunc = science.stats.loess()
    acc = params.get 'acc'
    bandwidth = params.get 'bandwidth'
    bandwidth = Math.max bandwidth, 3.0/xs.length
    loessfunc.bandwidth bandwidth
    loessfunc.accuracy acc
    @log "nxs: #{xs.length}\tnys: #{ys.length}"
    @log.warn "bw: #{bandwidth}\tacc: #{acc}"

    smoothys = loessfunc(xs, ys)
    @log "#{_.reject(smoothys, _.isValid).length} ys rejected post-loess"
    rows = []
    _.times xs.length, (idx) ->
      # sometimes it interpolates to NaN values
      if _.isValid(smoothys[idx]) and _.isValid(xs[idx])
        rows.push
          x: xs[idx]
          y: smoothys[idx]

    @log "compute: xs: #{JSON.stringify xs.slice(0,6)}"
    @log "compute: ys: #{JSON.stringify ys.slice(0,6)}"
    @log "compute: smoothys: #{JSON.stringify smoothys.slice(0,6)}"

    schema = params.get('outputSchema') data, params
    data.table = new gg.data.RowTable schema, rows
    data
