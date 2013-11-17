#<< data/table

class data.ops.Aggregate extends data.Table
  # @param aggs of the form
  #   col:
  #    f: (table) -> val
  #    type: schema type (default: schema.object)
  #    
  # XXX: support incremental aggs
  constructor: (@table, @aggs) ->
    @schema = @table.schema
    unless @schema.has 'table', data.Schema.table
      throw Error "Aggregate doesn't have table column"
    @schema = @schema.exclude 'table'
    _.each @aggs, (agg, col) =>
      agg.type ?= data.Schema.object
      @schema.addColumn col, agg.type

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

        _.each @aggs, (agg, col) ->
          val = agg.f row.get('table'), @idx
          newrow.set col, val
        newrow

      hasNext: -> @iter.hasNext()
      close: -> @iter.close()

    new Iter @schema, @table, @aggs


   


