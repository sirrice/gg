class gg.data.EquiHashJoin extends gg.data.Table

  constructor: (@t1, @t2, @cols) ->
    @schema = @t1.schema.clone()
    @schema.merge @t2.schema.clone()
    @schema.addColumn 'left', gg.data.Schema.object
    @schema.addColumn 'right', gg.data.Schema.object
    @getkey = (row) -> _.map cols, (col) -> row.get(col)

  setup: ->
    ht1 = gg.data.Partition.buildHT @t1, @cols
    strkeys = _.uniq _.flatten [_.keys(ht1), _.keys(ht2)]

  iterator: ->
    class Iter
      constructor: (@table, @ht, @schema, @getkey) ->
        @iter = @table.iterator()
        @_left = null
        @_inner = null
        @_next = null

      reset: -> @iter.reset()

      next: -> 
        throw Error("iterator has no more elements") unless @_next?
        @_left.clone().merge(@_next)

      hasNext: -> 
        return true if @_next?
        @_next = @getNext()
        @_next?

      getNext: ->
        if @_left?
          if @idx < @_inner.table.length
            @idx += 1
            return @_inner.table.length[@idx-1]
          else
            # need new left
            @_left = null

        while not(@_left?) and @iter.hasNext()
          @_inner = null
          @idx = 0
          @_left = @iter.next()
          keystr = JSON.stringify(@getkey @_left)
          @_inner = @ht[keystr]
          if @idx < @_inner.table.length
            @idx += 1
            return @_inner.table.length[@idx-1]
          @left = null

        null

      close: -> 
        @table = null
        @iter.close()

    new Iter @schema, @table, @cols

