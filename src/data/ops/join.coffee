#<< data/table

class data.ops.EquiHashJoin extends data.Table

  constructor: (@t1, @t2, @cols) ->
    @schema = @t1.schema.clone()
    @schema.merge @t2.schema.clone()
    @schema.addColumn 'left', data.Schema.object
    @schema.addColumn 'right', data.Schema.object
    @getkey = (row) -> _.map cols, (col) -> row.get(col)
    @ht = data.ops.Util.buildHT @t2, @cols


  iterator: ->
    class Iter
      constructor: (@table, @ht, @getkey) ->
        @iter = @table.iterator()
        @_left = null
        @_inner = null  # rows in the inner of the join
        @_next = null
        @idx = 0

      reset: -> @iter.reset()

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        next = @_next
        @_next = null
        @_left.clone().merge(next)

      hasNext: -> 
        return true if @_next?
        @_next = @getNext()
        @_next?

      getNext: ->
        if @_left?
          if @_inner? and @idx < @_inner.length
            @idx += 1
            return @_inner[@idx-1]

          # need new left
          @_left = null
          @_inner = null

        while @iter.hasNext()
          @_left = @iter.next()
          keystr = JSON.stringify(@getkey @_left)
          unless keystr of @ht
            @_left = null
            continue

          @idx = 0
          @_inner = @ht[keystr].table
          if @idx < @_inner.length
            @idx += 1
            return @_inner[@idx-1]

        null

      close: -> 
        @table = null
        @iter.close()

    new Iter @t1, @ht, @getkey
