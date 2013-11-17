#<< data/table

class data.ops.Partition extends data.Table

  constructor: (@table, @cols) ->
    @cols = _.flatten [@cols]
    @schema = @table.schema.project @cols
    @schema.addColumn 'table', data.Schema.table

  iterator: ->
    class Iter
      constructor: (@schema, @table, @cols) ->
        @idx = 0

      reset: -> 
        @idx = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        row = new data.Row @schema
        htrow = @ht[@idx]
        @idx += 1
        for col, idx in @cols
          row.set col, htrow.key[idx]
        row.set 'table', htrow.table
        row

      hasNext: -> 
        unless @ht?
          @ht = _.values(data.ops.Util.buildHT @table, @cols)
        @idx < @ht.length

      close: -> 
        @table = null

    new Iter @schema, @table, @cols



