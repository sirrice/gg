#<< data/table

class data.ops.HashJoin extends data.Table

  constructor: (@t1, @t2, @cols, @jointype) ->
    @schema = @t1.schema.clone()
    @schema.merge @t2.schema.clone()
    @getkey = (row) -> _.map cols, (col) -> row.get(col)
    @ht1 = data.ops.Partition.buildHT @t1, @cols
    @ht2 = data.ops.Partition.buildHT @t2, @cols

  @arrayjoinIterator: (a1, a2, jointype) ->
    class Iter
      constructor: (@a1, @a2) ->
        @idx1 = 0
        @idx2 = 0

      reset: ->
        @idx1 = 0
        @idx2 = 0

      next: ->
        throw Error("iterator has no more elements") unless @hasNext()
        r1 = @a1[@idx1]
        r2 = @a2[@idx2]
        @idx2 += 1
        r1.clone().merge r2

      hasNext: ->
        while @idx1 < @a1.length and @idx2 >= @a2.length
          @idx2 = 0
          @idx1 += 1
        @idx1 < @a1.length

      close: ->
        @a1 = @a2 = null

    a1 ?= []
    a2 ?= []

    switch jointype
      when "left"
        if a2.length == 0
          a2 = [new data.Row(new data.Schema)]
      when "right"
        if a1.length == 0
          a1 = [new data.Row(new data.Schema)]
      when "outer"
        a1 = [new data.Row(new data.Schema)] if a1.length == 0
        a2 = [new data.Row(new data.Schema)] if a2.length == 0
          
    new Iter a1, a2

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
          left = []
          left = @ht1[@key].table if @key of @ht1
          right = []
          right = @ht2[@key].table if @key of @ht2
          @iter = data.ops.HashJoin.arrayjoinIterator left, right, @jointype
          if @iter.hasNext()
            break
          @iter = null

        @iter != null and @iter.hasNext()

      close: -> 
        @ht1 = @ht2 = null
        @iter.close() if @iter?
        @iter = null

    new Iter @ht1, @ht2, @jointype
