class gg.Stat extends gg.XForm
  constructor: (@layer, @spec={}) ->
    super @layer.g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.IdentityStat
      gg.Bin1DStat
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


class gg.IdentityStat extends gg.Stat
  @aliases = ['identity']


class gg.Bin1DStat extends gg.Stat
  @aliases = ['1dbin', 'bin', 'bin1d']


  parseSpec: ->
    @nbins = findGood [@spec.nbins, @spec.bins, 30]
    super

  inputSchema: (table, env, node) -> ['x']
  outputSchema: (table, env, node) ->
    ['x', 'y', 'bin', 'count', 'total']

  compute: (table, env, node) ->
    console.log "BIN!"
    scales = @scales table, env

    domain = scales.scale('x').domain()
    domain = scales.scale('x').defaultDomain table.getColumn('x')
    range = domain[1] - domain[0]
    binSize = Math.ceil(range / (@nbins))
    console.log "nbins: #{@nbins}\tdomain: #{domain}\tbinSize: #{binSize}"

    stats = _.map _.range(Math.ceil(range / binSize)+1), (binidx) ->
      {bin: binidx, count: 0, total: 0}

    table.each (row) ->
      x = row.get('x')
      y = row.get('y')
      binidx = Math.floor((x - domain[0]) / binSize)
      try
        stats[binidx].count += 1
      catch error
        console.log "fuck"
        console.log "fetch bin: #{x}:  #{binidx} of #{stats.length}"
        console.log stats
        throw error
      if _.isNumber y
        stats[binidx].total += y
      else
        stats[binidx].total += 1

    _.each stats, (stat) ->
      stat.bin = (stat.bin * binSize) + domain[0] + binSize/2
      stat.sum = stat.total
      stat.x = stat.bin
      stat.y = stat.count

    new gg.RowTable stats

