#<< gg/stat/stat

science = require 'science'

# loess algorithm:
#
# for each point
#   f = fit a polynomial to ceil(bw*n) closest points
#   update y as f(x) instead of original value
#
# bw IN   [(lambda + 1) / n, 1]
# lambda: degree of polynomial to fit
#
# This implementation uses lambda = 1
#
class gg.stat.Loess extends gg.wf.SyncExec
  @ggpackage = "gg.stat.Loess"
  @aliases = ['loess', 'smooth']

  parseSpec: ->
    super
    @params.ensureAll
      bandwidth: [["band", "bw"], .3]
      acc: [["accuracy", "ac"], 1e-12]

  inputSchema: -> ['x', 'y']

  outputSchema:  ->
    data.Schema.fromJSON
      x: data.Schema.numeric
      y: data.Schema.numeric

  schemaMapping: ->
    x: 'x'
    y: 'y'

  compute: (pairtable, params) ->
    table = pairtable.left()
    table = table.filter (row) ->
      _.isValid(row.get 'x') and _.isValid(row.get 'y')
    
    return pairtable if table.nrows() <= 1

    table = table.orderby 'x'
    xs = table.all 'x'
    ys = table.all 'y'

    loessfunc = science.stats.loess()
    acc = params.get 'acc'
    bw = params.get 'bandwidth'
    bw = Math.max bw, 2.0/xs.length
    bw = Math.min bw, 1.0
    loessfunc.bandwidth bw
    loessfunc.accuracy acc

    smoothys = loessfunc xs, ys
    table = table.project [{
      alias: 'y'
      f: (y, idx) -> smoothys[idx]
    }]
    pairtable.left table
    pairtable
