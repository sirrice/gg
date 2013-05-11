class gg.Stat extends gg.XForm
  constructor: (@layer, @spec={}) ->
    super @layer.g, @spec

    @map = null


    @parseSpec()

  parseSpec: ->
    if findGoodAttr(@spec, ['aes', 'aesthetic', 'mapping', 'map'], null)?
      mapSpec = _.clone @spec
      mapSpec.name = "stat-map" unless mapSpec.name?
      @map = gg.Mapper.fromSpec @g, mapSpec


  @klasses: ->
    klasses = [
      gg.IdentityStat
      gg.Bin1DStat
      gg.BoxplotStat
      gg.LoessStat
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret


  @fromSpec: (layer, spec) ->
    klasses = gg.Stat.klasses()
    console.log klasses
    if _.isString spec
      type = spec
      spec = {}
    else
      type = findGood [spec.type, spec.stat, "identity"]

    klass = klasses[type] or gg.IdentityStat
    ret = new klass layer, spec
    ret


  compile: ->
    node = super
    ret = []
    ret.push @map.compile() if @map?
    ret.push node
    _.compact _.flatten ret




class gg.IdentityStat extends gg.Stat
  @aliases = ['identity']


class gg.Bin1DStat extends gg.Stat
  @aliases = ['1dbin', 'bin', 'bin1d']


  parseSpec: ->
    @nbins = findGood [@spec.nbins, @spec.bins, 30]
    super

  inputSchema: (table, env, node) -> ['x']
  outputSchema: (table, env, node) ->
    gg.Schema.fromSpec
      x: table.schema.type 'x'
      bin: table.schema.type 'x'
      y: gg.Schema.numeric
      count: gg.Schema.numeric
      total: gg.Schema.numeric

  compute: (table, env, node) ->
    scales = @scales table, env
    xType = table.schema.type 'x'

    xScale = scales.scale 'x', xType
    domain = xScale.domain()
    #domain = xScale.defaultDomain table.getColumn('x')
    binRange = domain[1] - domain[0]
    binSize = Math.ceil(binRange / (@nbins))
    nBins = Math.ceil(binRange / binSize) + 1
    @log "nbins: #{@nbins}\tscaleid: #{xScale.id}\tscaledomain: #{xScale.domain()}\tdomain: #{domain}\tbinSize: #{binSize}"

    stats = _.map _.range(nBins), (binidx) ->
      {bin: binidx, count: 0, total: 0}

    table.each (row) ->
      x = row.get('x')
      y = row.get('y') || 0
      binidx = Math.floor((x - domain[0]) / binSize)
      try
        stats[binidx].count += 1
      catch error
        console.log "Bin1D.compute: #{error}"
        console.log "fetch bin: val(#{x}):  #{binidx} of #{stats.length}"
        return
      if _.isNumber y
        stats[binidx].total += y
      else
        stats[binidx].total += 1

    # augment rows with additional attributes
    _.each stats, (stat) ->
      stat.bin = (stat.bin * binSize) + domain[0] + binSize/2
      stat.sum = stat.total
      stat.x = stat.bin
      stat.y = stat.total

    new gg.RowTable @outputSchema(table, env, node), stats

class gg.BoxplotStat extends gg.Stat
  @aliases = ['boxplot']

  defaults: ->
    group: "1"
  inputSchema: (table, env, node) -> ['x', 'group']
  outputSchema: ->
    gg.Schema.fromSpec
      group: gg.Schema.ordinal
      q1: gg.Schema.numeric
      q3: gg.Schema.numeric
      median: gg.Schema.numeric
      lower: gg.Schema.numeric
      upper: gg.Schema.numeric
      outliers:
        type: gg.Schema.array
        schema:
          outlier: gg.Schema.numeric
      min: gg.Schema.numeric
      max: gg.Schema.numeric

  computeStatistics: (vals) ->
    vals.sort d3.ascending

    q1 = d3.quantile vals, 0.25
    median = d3.quantile vals, 0.5
    q3 = d3.quantile vals, 0.75
    min = if vals.length then vals[0] else null
    max = if vals.length then vals[vals.length - 1] else null
    fr = 1.5 * (q3-q1)
    lowerIdx = d3.bisectLeft vals, q1 - fr
    upperIdx = (d3.bisectRight vals, q3 + fr, lowerIdx) - 1
    lower = vals[lowerIdx]
    upper = vals[upperIdx]
    outliers = vals.slice(0, lowerIdx).concat(vals.slice(upperIdx + 1))

    outliers = _.map outliers, (v) -> {outlier: v}

    {
      q1: q1,
      median: median,
      q3: q3,
      lower: lower,
      upper: upper,
      outliers: outliers,
      min: min,
      max: max
    }


  compute: (table, env, node) ->
    groups = table.split "group"
    rows = _.map groups, (groupPair) =>
      gTable = groupPair.table
      gKey = groupPair.key
      vals = gTable.getColumn 'x'
      row = @computeStatistics vals
      row.group = gKey
      row

    table = new gg.RowTable @outputSchema(), rows
    console.log table.raw()
    table






class gg.LoessStat extends gg.Stat
  @aliases = ['loess', 'smooth']


  parseSpec: ->
    super

  inputSchema: (table, env, node) -> ['x', 'y']
  outputSchema: (table, env, node) ->
    gg.Schema.fromSpec
      x: gg.Schema.numeric
      y: gg.Schema.numeric

  compute: (table, env, node) ->
    xs = table.getColumn('x')
    ys = table.getColumn('y')
    xys = _.zip(xs, ys)
    xys.sort (xy1, xy2) -> xy1[0] - xy2[0]
    xs = xys.map (xy) -> xy[0]
    ys = xys.map (xy) -> xy[1]
    loessfunc = science.stats.loess()

    smoothys = loessfunc(xs, ys)
    console.log xs
    console.log ys
    console.log smoothys
    rows = []
    _.times xs.length, (idx) ->
      rows.push
        x: xs[idx]
        y: smoothys[idx]

    new gg.RowTable @outputSchema(), rows
