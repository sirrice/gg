
class gg.data.Filter extends gg.data.Table
  constructor: (@table, @f) ->

  iterator: ->
    class Iter
      constructor: (@table, @f) ->
        @schema = @table.schema
        @iter = @table.iterator()
        @_next = null

      reset: -> @table.reset()
      next: -> 
        throw Error("iterator has no more elements") unless @_next?
        ret = @_next
        @_next = null
        ret

      hasNext: -> 
        while @iter.hasNext()
          row = @iter.next()
          if @f row
            @_next = row
            return true
        false

      close: -> 
        @table = null
        @iter.close()

    new Iter @table, @f



