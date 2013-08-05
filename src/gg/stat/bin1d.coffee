#<< gg/stat/stat


class gg.stat.Bin1DStat extends gg.stat.Stat
  @ggpackage = "gg.stat.Bin1DStat"
  @aliases = ['1dbin', 'bin', 'bin1d']


  parseSpec: ->
    super
    @params.put 'nbins', _.findGoodAttr @spec, ["n", "bins", "bins"], 30

  inputSchema: (data, params) -> ['x']

  outputSchema: (data, params) ->
    table = data.table
    gg.data.Schema.fromSpec
      x: table.schema.type 'x'
      bin: table.schema.type 'x'
      y: gg.data.Schema.numeric
      count: gg.data.Schema.numeric
      total: gg.data.Schema.numeric

  schemaMapping: (data, params) ->
    x: 'x'
    bin: 'x'
    y: 'y'
    count: 'y'
    total: 'y'

  compute: (data, params) ->
    table = data.table
    env = data.env
    scales = @scales data, params
    xType = table.schema.type 'x'
    xScale = scales.scale 'x', xType
    domain = xScale.domain()

    switch xType
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
        stats = _.times nBins, (binidx) ->
          {
            bin: (binidx * binSize) + domain[0] + binSize/2
            count: 0
            total: 0
          }

      when gg.data.Schema.date
        domain = [domain[0].getTime(), domain[1].getTime()]
        binRange = domain[1] - domain[0]
        nbins = params.get 'nbins'
        binSize = Math.ceil(binRange / nbins)
        nBins = Math.ceil(binRange/binSize) + 1
        @log "nbins: #{nbins}\tscaleid: #{xScale.id}\tscaledomain: #{xScale.domain()}\tdomain: #{domain}\tbinSize: #{binSize}"
        toBinidx = (x) -> Math.floor((x.getTime()-domain[0]) / binSize)
        stats = _.times nBins, (binidx) ->
          date = (binidx * binSize) + domain[0] + binSize/2
          date = new Date date
          {
            bin: date
            count: 0
            total: 0
          }

      else
        throw Error("I don't support binning on col type: #{xType}")

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

    schema = params.get('outputSchema') data, params
    @log _.map(stats, (s) -> s.x)
    data.table = new gg.data.RowTable schema, stats
    data


