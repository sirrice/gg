#<< gg/core/xform

class gg.xform.GroupByAnnotate extends gg.core.XForm
  @ggpackage = "gg.xform.GroupByAnnotate"

  parseSpec: ->
    @log @params
    @params.ensureAll
      gbAttrs: [[], []]
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


  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    origSchema = table.schema

    scales = md.get 0, 'scales'
    gbAttrs = params.get "gbAttrs"
    nBins = params.get "nBins"
    Transform = gg.data.Transform


    @log "scales: #{scales.toString()}"
    @log "get mapping functions on #{gbAttrs}, #{nBins}"
    mapping = @constructor.getHashFuncs(
      gbAttrs, origSchema, nBins, scales
    )
    if _.size(mapping) > 0
      table = Transform.transform table, mapping
    new gg.data.PairTable table, md


  # Create hash functions 
  @getHashFuncs: (gbAttrs, schema, nBins, scales) ->
    _.o2map gbAttrs, (gbAttr, idx) ->
      type = schema.type gbAttr
      scale = scales.scale gbAttr, type
      domain = scale.domain()
      keyF = gg.xform.GroupByAnnotate.getHashFunc(
        gbAttr, type, nBins[idx], domain)
      [gbAttr, keyF]

  # Given a table column and its scale, return hash function
  # that produces the correct number of buckets
  @getHashFunc = (col, type, nbins, domain) ->
    toKey = (row) -> row.get col
    if nbins == -1
      type = gg.data.Schema.ordinal

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
#
# Create group by attributes, functions understand how to create
# bucketized groups
#
# This class is special because the functions to create the
# grouping variables can only be created at runtime
# Doesn't this overlap with Exec?
#
class gg.xform.GroupBy extends gg.core.XForm
  @ggpackage = "gg.xform.GroupBy"

  
  parseSpec: ->
    @log @params
    @params.ensureAll
      gbAttrs: [[], []]
      aggFuncs: [["agg", "aggs"], {}]
      nBins: [["nbins", "bin", "n", "nbin", "bins"], 20]

    @annotate = new gg.xform.GroupByAnnotate 
      params: 
        gbAttrs: @params.get('gbAttrs')
        nBins: @params.get('nBins')

    super

  compile: ->
    nodes = super
    nodes.unshift @annotate.compile()
    nodes

  inputSchema: (pairtable, params) ->
    params.get("gbAttrs")

  outputSchema: (pairtable, params) ->
    gbAttrs = params.get "gbAttrs"
    aggFuncs = params.get "aggFuncs"
    schema = pairtable.tableSchema().clone()

    # XXX: assume that the aggregate functions output numeric types
    spec = {}
    for aggName, agg of aggFuncs
      spec[aggName] =  gg.data.Schema.numeric
    newSchema = gg.data.Schema.fromJSON spec
    schema.merge newSchema

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()

    gbAttrs = params.get "gbAttrs"
    partitions = table.partition gbAttrs
    rows = []
    for p in partitions
      rows.push.apply rows, @udf(p, params)

    outputSchema = params.get('outputSchema') pairtable, params
    newtable = gg.data.Table.fromArray rows, outputSchema
    new gg.data.PairTable newtable, md

  udf: (table, params) ->
    aggFuncs = params.get 'aggFuncs'
    gg.xform.GroupBy.aggregatePartition aggFuncs, table

  @aggregatePartition: (aggFuncs, table) ->
    aggVals = _.o2map aggFuncs, (spec, name) ->
      agg = gg.xform.Aggregate.fromSpec spec
      v = agg.compute table
      [name, v]
    row = table.get(0).raw()
    _.extend row, aggVals
    [row]



