#<< gg/core/xform

class gg.xform.Quantize extends gg.wf.SyncExec
  @ggpackage = "gg.xform.Quantize"

  parseSpec: ->
    @log @params
    @params.ensureAll
      cols: [[], []]
      nBins: [['nBins', "nbins", "bin", "n", "nbin", "bins"], 20]

    cols = @params.get "cols"
    cols = _.compact _.flatten [cols]
    throw Error "need >0 cols to group on" if cols.length is 0

    # nBins keeps track of the number of distinct values for each
    # gbAttr attribute
    nBins = @params.get "nBins"
    nBins = _.times(cols.length, () -> nBins) if _.isNumber nBins
    unless nBins.length == cols.length
      throw Error "nBins length #{nBins.length} != cols length #{cols.length}"

    @params.put "nBins", nBins
    @log "nBins now #{JSON.stringify nBins}"
    super


  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    return pairtable if table.nrows() == 0

    schema = table.schema
    scales = md.any 'scales'
    cols = params.get "cols"
    nBins = params.get "nBins"
    return pairtable unless cols.length > 0
    @log "scales: #{scales.toString()}"
    @log "get mapping functions on #{cols}, #{nBins}"

    mapping = @constructor.getQuantizers(
      cols, schema, nBins, scales
    )
    @log mapping
    table = table.project mapping, yes
    pairtable.left table
    pairtable


  # Create hash functions 
  @getQuantizers: (cols, schema, nBins, scales) ->
    _.map cols, (col, idx) ->
      type = schema.type col
      scale = scales.scale col, type
      domain = scale.domain()
      f = gg.xform.Quantize.quantizer(
        col, type, nBins[idx], domain
      )
      {
        alias: col
        f
        type
        cols
      }



  # Given a table column and its domain, return hash function
  # that maps value in the domain to a bucket index
  @quantizer: (col, type, nbins, domain) ->
    toKey = (row) -> row.get col
    if nbins == -1
      type = data.Schema.ordinal

    switch type
      when data.Schema.ordinal
        toKey = (row) -> row.get col

      when data.Schema.numeric
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        toKey = (row) -> 
          idx = Math.ceil((row.get(col)-minD) / binSize - 1)
          idx = Math.max(0, idx)
          (idx * binSize) + minD + (binSize / 2)

      when data.Schema.date
        domain = [domain[0].getTime(), domain[1].getTime()]
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = Math.ceil(binRange / nbins)
        toKey = (row) ->
          time = row.get(col).getTime()
          idx = Math.ceil((time-minD) / binSize - 1)
          idx = Math.max(0, idx)
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
# cols: list of column names to group on
# aggs: map of aggregate name -> aggregate function spec
#       or
#       list of data.ops.aggregate aggregation descs
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
      cols: [[], []]
      aggs: [["agg", "aggs"], {}]
      nBins: [["nbins", "bin", "n", "nbin", "bins"], 20]

    @annotate = new gg.xform.Quantize
      name: "#{@name}-quantize"
      params: 
        cols: @params.get('cols')
        nBins: @params.get('nBins')

    # turn aggs into actual aggregate specs for table.aggregate
    aggs = @params.get 'aggs'
    aggs = _.map aggs, (spec, name) ->
      if spec? and spec.alias? and spec.f? and _.isFunction spec.f
        return spec
      type = spec.type unless _.isString spec
      type = spec if _.isString spec
      col = spec.col
      col ?= 'y'
      args = []
      args = spec.args if spec.args?
      data.ops.Aggregate.agg type, name, col, args...
    @params.put 'aggs', aggs

    super

  inputSchema: (pairtable, params) ->
    params.get("cols")

  outputSchema: (pairtable, params) ->
    cols = params.get "cols"
    aggs = params.get "aggs"
    schema = pairtable.leftSchema().clone()

    # XXX: assume that the aggregate functions output numeric types
    spec = {}
    for aggName, agg of aggFuncs
      spec[aggName] =  data.Schema.numeric
    newSchema = data.Schema.fromJSON spec
    schema.merge newSchema

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()

    cols = params.get 'cols'
    aggs = params.get 'aggs'
    table = table.groupby cols, aggs
    table = table.flatten()
    pairtable.left table
    pairtable


  compile: ->
    nodes = super
    nodes.unshift @annotate.compile()
    nodes
