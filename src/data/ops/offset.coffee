#<< data/table

class data.ops.Offset extends data.Table
  constructor: (@table, @n) ->
    @schema = @table.schema

  iterator: ->
    class Iter
      constructor: (@table, @n) ->
        @schema = @table.schema
        @iter = @table.iterator()
        @_next = null
        @reset()

      reset: -> 
        @iter.reset()
        i = 0
        until i >= @n or not @iter.hasNext()
          @iter.next()
          i += 1

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()?
        @iter.next()

      hasNext: -> @iter.hasNext()

      close: -> 
        @table = null
        @iter.close()

    new Iter @table, @n



