#<< gg/stat/stat

science = require 'science'

class gg.stat.Loess extends gg.stat.Stat
  @ggpackage = "gg.stat.Loess"
  @aliases = ['loess', 'smooth']

  parseSpec: ->
    super
    @params.ensureAll
      bandwidth: [["band", "bw"], .3]
      acc: [["accuracy", "ac"], 1e-12]

  inputSchema: -> ['x', 'y']

  outputSchema:  ->
    gg.data.Schema.fromJSON
      x: gg.data.Schema.numeric
      y: gg.data.Schema.numeric

  schemaMapping: ->
    x: 'x'
    y: 'y'

  # The loess function expects an xs and ys array where
  # 1) every value is a finite number
  # 2) xs is monotonically increasing
  compute: (pairtable, params) ->
    table = pairtable.getTable()
    if table.nrows() <= 1
      return pairtable

    @log "nrows:   #{table.nrows()}"
    @log "schema:  #{table.schema.toString()}"
    xs = table.getColumn 'x'
    ys = table.getColumn 'y'
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
    rows = _.compact _.map _.zip(xs, smoothys), ([x,y]) ->
      { x: x, y: y } if _.isValid(y) and _.isValid(x)

    @log "#{smoothys.length - rows.length} rejected post-loess"
    @log "compute: xs: #{JSON.stringify xs.slice(0,6)}"
    @log "compute: ys: #{JSON.stringify ys.slice(0,6)}"
    @log "compute: smoothys: #{JSON.stringify smoothys.slice(0,6)}"

    table = gg.data.Table.fromArray rows
    new gg.data.PairTable table, pairtable.getMD()
