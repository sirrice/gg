#<< data/table

class data.ops.Aggregate extends data.Table
  # @param aggs of the form
  #    alias: col | [col, ...]
  #    f: (table) -> val
  #    type: schema type    (default: schema.object)
  #    col: col | [col*]    columnsaccessed in aggregate function
  #    
  #   if alias is a list, then f is expected to return a dictionary 
  #
  # XXX: support incremental aggs
  constructor: (@table, @aggs) ->
    @schema = @table.schema
    unless @schema.has 'table', data.Schema.table
      throw Error "Aggregate doesn't have table column"
    @schema = @schema.exclude 'table'
    _.each @aggs, (agg) =>
      agg.type ?= data.Schema.object
      if _.isArray agg.alias
        if _.isArray agg.type
          unless agg.alias.length  == agg.type.length
            throw Error "alias and type lens don't match: #{desc.alias} != #{desc.type}"
        else
          agg.type = _.times agg.alias.length, () -> agg.type

        for col, idx in agg.alias
          @schema.addColumn col, agg.type[idx]
      else
        @schema.addColumn agg.alias, agg.type

  iterator: ->
    class Iter
      constructor: (@schema, @table, @aggs) ->
        @iter = @table.iterator()
        @idx = -1

      reset: -> 
        @iter.reset()
        @idx = -1

      next: ->
        @idx += 1
        row = @iter.next()
        newrow = row.project @schema

        _.each @aggs, (agg) ->
          if _.isArray agg.alias
            o = agg.f row.get('table'), @idx
            for col in agg.alias
              newrow.set col, o[col]
          else
            val = agg.f row.get('table'), @idx
            newrow.set agg.alias, val
        newrow

      hasNext: -> @iter.hasNext()
      close: -> @iter.close()

    new Iter @schema, @table, @aggs


   


  #
  # static methods for creating aggregate specifications
  # (@aggs) param in Aggregate.constructor
  #

  @count: (alias="count") ->
    f = (arr) -> 
      if arr?
        arr.length
      else 
        0
    {
      alias: alias
      f: f
      type: data.Schema.numeric
      col: []
    }

  @sums: (cols, aliases) ->
    unless _.isArray alias 
      alias = []
    while alias.length < cols.length
      alias.push "sum#{alias.length}"
    _.map cols, (col, idx) ->
      data.ops.Aggregate.sum col, alias[idx]

  # @param col column name of list of column names
  @sum: (col, alias='sum') ->

    f = (arr) ->
      sum = 0
      for row in arr
        v = row.get col
        if _.isValid v
          sum += v
      sum
    {
      alias: alias
      f: f
      type: data.Schema.numeric
      col: col
    }
        

