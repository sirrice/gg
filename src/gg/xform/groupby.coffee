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
    gbAttrs = _.compact _.flatten [gbAttrs]
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

  inputSchema: (pairtable, params) ->
    params.get("gbAttrs")

  outputSchema: (pairtable, params) ->
    gbAttrs = params.get "gbAttrs"
    aggFuncs = params.get "aggFuncs"
    schema = pairtable.tableSchema()

    # XXX: assume that the aggregate functions output numeric types
    spec = {}
    for aggName, agg of aggFuncs
      spec[aggName] =  gg.data.Schema.numeric
    for gbAttr in gbAttrs
      spec[gbAttr] = schema.type gbAttr

    gg.data.Schema.fromJSON spec

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    origSchema = table.schema

    scales = md.get 0, 'scales'
    gbAttrs = params.get "gbAttrs"
    aggFuncs = params.get "aggFuncs"
    nBins = params.get "nBins"


    @log "scales: #{scales.toString()}"
    @log "get mapping functions on #{gbAttrs}, #{nBins}"
    mapping = gg.xform.GroupBy.getMappingFunctions(
      gbAttrs, origSchema, nBins, scales)
    table = gg.data.Transform.transform table, mapping
    partitions = gg.data.Transform.partition table, gbAttrs
    rows = _.map partitions, (p) ->
      gg.xform.GroupBy.aggregatePartition(aggFuncs, p['table'])

    outputSchema = params.get('outputSchema') pairtable, params
    newtable = gg.data.Table.fromArray rows, outputSchema
    #gg.wf.Stdout.print data.table, null, 5, @log
    new gg.data.PairTable newtable, md

  @aggregatePartition: (aggFuncs, table) ->
    aggVals = _.o2map aggFuncs, (spec, name) ->
      agg = gg.xform.Aggregate.fromSpec spec
      v = agg.compute table
      [name, v]
    row = table.get(0).raw()
    _.extend row, aggVals
    row


  @getMappingFunctions: (gbAttrs, schema, nBins, scales) ->
    _.o2map gbAttrs, (gbAttr, idx) ->
      type = schema.type gbAttr
      scale = scales.scale gbAttr, type
      domain = scale.domain()
      keyF = gg.xform.GroupBy.getMappingFunction(
        gbAttr, type, nBins[idx], scale)
      [gbAttr, keyF]

  @getMappingFunction = (col, type, nbins, scale) ->
    domain = scale.domain()
    toKey = (row) -> row.get col

    switch type
      when gg.data.Schema.ordinal
        toKey = (row) -> row.get col

      when gg.data.Schema.numeric
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        toKey = (row) -> 
          idx = Math.floor((row.get(col)+(binSize/2)-minD) / binSize)
          (idx * binSize) + minD - (binSize / 2)

      when gg.data.Schema.date
        domain = [domain[0].getTime(), domain[1].getTime()]
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        toKey = (row) ->
          time = row.get(col).getTime()
          idx = Math.floor((time-minD) / binSize)
          date = (idx * binSize) + minD + binSize/2
          new Date date

      else
        throw Error("I don't support binning on col type: #{type}")

    toKey

