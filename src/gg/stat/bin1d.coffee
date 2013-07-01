#<< gg/stat/stat


class gg.stat.Bin1DStat extends gg.stat.Stat
  @ggpackage = "gg.stat.Bin1DStat"
  @aliases = ['1dbin', 'bin', 'bin1d']


  parseSpec: ->
    super
    @params.put 'nbins', _.findGoodAttr @spec, ["n", "bins", "bins"], 30

  inputSchema: (table, env, params) -> ['x']

  outputSchema: (table, env, params) ->
    gg.data.Schema.fromSpec
      x: table.schema.type 'x'
      bin: table.schema.type 'x'
      y: gg.data.Schema.numeric
      count: gg.data.Schema.numeric
      total: gg.data.Schema.numeric

  compute: (table, env, params) ->
    scales = @scales table, env, params
    xType = table.schema.type 'x'
    xScale = scales.scale 'x', xType
    domain = xScale.domain()

    switch table.schema.type 'x'
      when gg.data.Schema.ordinal
        xtoidx = _.o2map domain, (x, idx) -> [x, idx]
        toBinidx = (x) -> xtoidx[x]
        stats = _.map domain, (x) ->
          {bin: x, count: 0, total: 0}
      when gg.data.Schema.numeric
        binRange = domain[1] - domain[0]
        nbins = params.get 'nbins'
        binSize = Math.ceil(binRange / nbins)
        nBins = Math.ceil(binRange / binSize) + 1
        @log "nbins: #{nbins}\tscaleid: #{xScale.id}\tscaledomain: #{xScale.domain()}\tdomain: #{domain}\tbinSize: #{binSize}"
        toBinidx = (x) -> Math.floor((x-domain[0]) / binSize)
        stats = _.map _.range(nBins), (binidx) ->
          {
            bin: (binidx * binSize) + domain[0] + binSize/2
            count: 0
            total: 0
          }

    table.each (row) =>
      x = row.get('x')
      y = row.get('y') || 0
      binidx = toBinidx x
      try
        stats[binidx].count += 1
      catch error
        @log.warn "Bin1D.compute: #{error}"
        @log.warn "fetch bin: val(#{x}):  #{binidx} of #{stats.length}"
        return
      if _.isNumber y
        stats[binidx].total += y
      else
        stats[binidx].total += 1

    # augment rows with additional attributes
    _.each stats, (stat) ->
      stat.sum = stat.total
      stat.x = stat.bin
      stat.y = stat.total

    schema = params.get('outputSchema') table, env, params
    console.log _.map(stats, (s) -> s.x)
    new gg.data.RowTable schema, stats


