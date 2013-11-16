class gg.data.Union extends gg.data.Table
  constructor: (@table, @rows) ->

  iterator: ->
    class Iter
      constructor: (@table, @rows) ->
        @schema = @table.schema
        @iter = @table.iterator()
        @state = 0  # 0 for table, 1 for rows
        @idx = 0

      reset: -> 
        @iter.reset()
        @idx = 0
        @state = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        if @state == 0
          @iter.next()
        else
          @idx += 1
          @rows[@idx - 1]

      hasNext: -> 
        if @state == 0
          if @iter.hasNext()
            return true
          else
            @state = 1
        @idx < @rows.length

      close: -> 
        @table = null
        @iter.close()

    new Iter @table, @rows


