#<< data/table

class data.ops.Filter extends data.Table
  constructor: (@table, @f) ->
    @schema = @table.schema

  iterator: ->
    class Iter
      constructor: (@table, @f) ->
        @schema = @table.schema
        @iter = @table.iterator()
        @_next = null

      reset: -> @iter.reset()
      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()?
        ret = @_next
        @_next = null
        ret

      hasNext: -> 
        return true if @_next?
        while @iter.hasNext()
          row = @iter.next()
          if @f row
            @_next = row
            break
        @_next?

      close: -> 
        @table = null
        @iter.close()

    new Iter @table, @f



