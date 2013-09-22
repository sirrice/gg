#<< gg/core/xform

# Implements
#
#   SELECT   agg1(), .., aggN(), gbkeys
#   FROM     input table
#   GROUPBY  gbkeys
#
# Params:
#
# gbAttrs: list of column names to group on
# aggFuncs: map of aggregate name -> aggregate function
#           the function takes a gg.data.Table as input and outputs a value
#
class gg.xform.GroupBy extends gg.core.XForm
  @ggpackage = "gg.xform.GroupBy"

  
  parseSpec: ->
    @log @params
    @params.ensureAll
      gbAttrs: [[], []]
      aggFuncs: [["agg", "aggs"], {}]
      nBins: [["nbins", "bin", "n", "nbin", "bins"], 20]

    gbAttrs = @params.get "gbAttrs"
    throw Error() if gbAttrs.length is 0

    # nBins keeps track of the number of distinct values for each
    # gbAttr attribute
    nBins = @params.get "nBins"
    nBins = _.times gbAttrs.length, () -> nBins if _.isNumber nBins
    unless nBins.length == gbAttrs.length
      throw Error "nBins length #{nBins.length} != gbAttrs length #{gbAttrs.length}"
    @params.put "nBins", nBins
    @log "nBins now #{JSON.stringify nBins}"

    super

  inputSchema: (data, params) ->
    params.get("gbAttrs")

  outputSchema: (data, params) ->
    gbAttrs = params.get "gbAttrs"
    aggFuncs = params.get "aggFuncs"
    schema = data.table.schema

    # XXX: assume that the aggregate functions output numeric types
    spec = {}
    for aggName, agg of aggFuncs
      spec[aggName] =  gg.data.Schema.numeric
    for gbAttr in gbAttrs
      spec[gbAttr] = schema.type gbAttr

    gg.data.Schema.fromSpec spec

  compute: (data, params) ->
    table = data.table
    env = data.env
    origSchema = table.schema
    scales = env.get "scales"
    gbAttrs = params.get "gbAttrs"
    aggFuncs = params.get "aggFuncs"
    nBins = params.get "nBins"

    grouper = @constructor.getGrouper gbAttrs, origSchema, scales, nBins
    bins = new gg.xform.Bins grouper.nBins, aggFuncs

    schema = @outputSchema data, params
    data.table = @constructor.groupBy table, bins, grouper, schema
    gg.wf.Stdout.print data.table, null, 5, @log
    data



  @getGrouper: (gbAttrs, schema, scales, nBins) ->
    groupers = _.map gbAttrs, (gbAttr, idx) ->
      type = schema.type gbAttr
      scale = scales.scale gbAttr, type
      domain = scale.domain()
      new gg.xform.SingleKeyGrouper gbAttr, type, domain, nBins[idx]
    grouper = new gg.xform.MultiKeyGrouper groupers
    @log "group has #{grouper.nBins} bins"
    @log "groupBins: #{grouper.groupBins}"
    grouper

  @groupBy: (table, bins, grouper, schema) ->
    # First pass compute aggregates
    table.each (row) ->
      idx = grouper.toBinidx row
      for aggName, agg of bins.get(idx)
        agg.update row

    # turn each aggregate into row in new table
    rows = []
    for bin, binidx in bins.validBins()
      row = {}
      vals = grouper.fromBinidx binidx
      _.each vals, (val, idx) ->
        row[grouper.groupers[idx].name] = val

      for aggName, agg of bin
        row[aggName] = agg.value()
      rows.push row

    new gg.data.RowTable schema, rows

class gg.xform.Bins 
  constructor: (@maxBins, @aggFuncs) ->
    @bins = _.times @maxBins, () -> null

  # retrieve and/or create a new bin
  get: (idx) ->
    if idx < 0 or idx >= @maxBins
      throw Error
    unless @bins[idx]?
      @bins[idx] = @newBin()

    @bins[idx]

  validBins: -> _.compact @bins

  # Construct a new bin containing the aggregate functions to apply to 
  # the tuples that fall in the bin
  newBin: ->
    _.o2map @aggFuncs, (funcName, attrName) ->
      [attrName, gg.xform.Aggregate.fromSpec(funcName)]



class gg.xform.SingleKeyGrouper
  @ggpackage = "gg.xform.SingleKeyGrouper"

  constructor: (@col, @type, @domain, nbins=5) ->
    @log = gg.util.Log.logger @constructor.ggpackage, "1KeyGrouper"
    @name = @col

    @log "col: #{@col}, domain: #{@domain}"
    @log "nbins: #{nbins}"
    @setup nbins

  # compute the value -> bin mapping functions given the data type
  setup: (nbins) ->
    switch @type
      when gg.data.Schema.ordinal
        xtoidx = _.o2map @domain, (x, idx) -> [x, idx]
        @nBins = @domain.length
        @toBinidx = (row) => xtoidx[row.get @col]
        @fromBinidx = (idx) => @domain[idx]

      when gg.data.Schema.numeric
        [minD, maxD] = [@domain[0], @domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        @nBins = Math.ceil(binRange / binSize) + 1
        @toBinidx = (row) => 
          Math.floor((row.get(@col)+(binSize/2)-minD) / binSize)
        @fromBinidx = (idx) -> (idx * binSize) + minD - (binSize / 2)


      when gg.data.Schema.date
        @domain = [@domain[0].getTime(), @domain[1].getTime()]
        [minD, maxD] = [@domain[0], @domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        @nBins = Math.ceil(binRange/binSize) + 1
        @toBinidx = (row) => 
          Math.floor((row.get(@col).getTime()-minD) / binSize)
        @fromBinidx = (idx) => 
          date = (idx * binSize) + minD + binSize/2
          new Date date

      else
        throw Error("I don't support binning on col type: #{@type}")
    

    
class gg.xform.MultiKeyGrouper
  @ggpackage = "gg.xform.MultiKeyGrouper"

  constructor: (@groupers) ->
    @log = gg.util.Log.logger @constructor.ggpackage, "MultiGrouper"
    @groupBins = _.map @groupers, (grouper) -> grouper.nBins

    @nBins = 1
    @multipliers = []
    for n, idx in @groupBins
      @multipliers.push @nBins
      @nBins *= n

    @log "multipliers: #{@multipliers}"

  toBinidx: (row) ->
    ret = 0
    for grouper, idx in @groupers
      ret += grouper.toBinidx(row) * @multipliers[idx]
    ret

  fromBinidx: (binIdx) ->
    ret = []
    for idx in _.range(@multipliers.length-1, -1, -1)
      mult = @multipliers[idx]
      grouper = @groupers[idx]
      grouperIdx = Math.floor(binIdx / mult)
      binIdx = binIdx - (grouperIdx * mult)
      ret.push grouper.fromBinidx grouperIdx
    ret.reverse()




