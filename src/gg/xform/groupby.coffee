#<< gg/core/xform
#<< gg/xform/quantize



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
