#<< gg/stat/stat


class gg.stat.Bin1DStat extends gg.stat.Stat
  @aliases = ['1dbin', 'bin', 'bin1d']


  parseSpec: ->
    @nbins = _.findGoodAttr @spec, ["n", "bins", "bins"], 30
    super

  inputSchema: (table, env, node) -> ['x']
  outputSchema: (table, env, node) ->
    gg.data.Schema.fromSpec
      x: table.schema.type 'x'
      bin: table.schema.type 'x'
      y: gg.data.Schema.numeric
      count: gg.data.Schema.numeric
      total: gg.data.Schema.numeric

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

    table.each (row) =>
      x = row.get('x')
      y = row.get('y') || 0
      binidx = Math.floor((x - domain[0]) / binSize)
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
      stat.bin = (stat.bin * binSize) + domain[0] + binSize/2
      stat.sum = stat.total
      stat.x = stat.bin
      stat.y = stat.total

    new gg.data.RowTable @outputSchema(table, env, node), stats


