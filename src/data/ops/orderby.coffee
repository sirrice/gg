#<< data/table

class data.ops.OrderBy extends data.Table

  constructor: (@table, @cols, @reverse=no) ->
    @schema = @table.schema
    cols = _.flatten [@cols]
    reverse = if @reverse then -1 else 1
    @cmp = (r1, r2) ->
      for col in cols
        continue unless r1.has(col) and r2.has(col)
        if r1.get(col) > r2.get(col)
          return 1 * reverse
        if r1.get(col) < r2.get(col)
          return -1 * reverse
      return 0

  iterator: ->
    class Iter
      constructor: (@table, @cmp) ->
        @rows = null
        @schema = @table.schema
        @iter = @table.iterator()
        @idx = 0

      reset: -> 
        @idx = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        @idx += 1
        @rows[@idx - 1]

      hasNext: -> 
        unless @rows?
          @rows = []
          while @iter.hasNext()
            @rows.push @iter.next()
          @rows.sort @cmp
        @idx < @rows.length

      close: -> 
        @table = null
        @rows = null
        @iter.close()

    new Iter @table, @cmp
