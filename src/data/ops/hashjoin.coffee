#<< data/table

class data.ops.HashJoin extends data.Table

  constructor: (@t1, @t2, @cols, @jointype) ->
    @schema = @t1.schema.clone()
    @schema.merge @t2.schema.clone()
    @getkey = (row) -> _.map cols, (col) -> row.get(col)
    @ht1 = data.ops.Util.buildHT @t1, @cols
    @ht2 = data.ops.Util.buildHT @t2, @cols


  iterator: ->
    class Iter
      constructor: (@ht1, @ht2, @jointype) ->
        keys1 = _.keys @ht1
        keys2 = _.keys @ht2
        switch @jointype
          when "inner"
            @keys = _.intersection keys1, keys2
          when "left"
            @keys = keys1
          when "right"
            @keys = keys2
          when "outer"
            @keys = _.uniq _.flatten [keys1, keys2]
          else
            @keys = _.uniq _.flatten [keys1, keys2]

        @reset()

      reset: -> 
        @keyidx = -1
        @key = null
        @iter = null

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        @iter.next()

      hasNext: -> 
        if @iter? and not @iter.hasNext()
          @iter.close()
          @iter = null

        while @iter is null and @keyidx < @keys.length
          @keyidx += 1
          @key = @keys[@keyidx]
          left = right = []
          left = @ht1[@key].table if @key of @ht1
          right = @ht2[@key].table if @key of @ht2
          @iter = data.ops.Util.arrayjoinIterator left, right, @jointype
          break if @iter.hasNext()
          @iter = null

        @iter != null and @iter.hasNext()

      close: -> 
        @ht1 = @ht2 = null
        @iter.close() if @iter?
        @iter = null

    new Iter @ht1, @ht2, @jointype
