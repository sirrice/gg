#<< data/table

class data.ops.Limit extends data.Table
  constructor: (@table, @n) ->
    @schema = @table.schema

  iterator: ->
    class Iter
      constructor: (@table, @n) ->
        @schema = @table.schema
        @iter = @table.iterator()
        @idx = 0

      reset: -> 
        @iter.reset()
        @idx = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()?
        @idx += 1
        @iter.next()

      hasNext: -> @idx < @n and @iter.hasNext()

      close: -> 
        @table = null
        @iter.close()

    new Iter @table, @n



