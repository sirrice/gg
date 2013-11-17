

class data.ops.Util 

  #
  # build hash table based on equality of columns
  # @param cols columns to use for equality test
  # @return [ht, keys]  where
  #   ht = JSON.stringify(key) -> rows
  #   keys: JSON.stringify(key) -> key
  @buildHT: (t, cols) ->
    iter = t.iterator()
    getkey = (row) -> _.map cols, (col) -> row.get(col)
    ht = {}
    keys = {}
    while iter.hasNext()
      row = iter.next()
      key = getkey row
      strkey = JSON.stringify key
      # XXX: may need to use toJSON on key
      ht[strkey] = [] unless strkey of ht
      ht[strkey].push row
      keys[strkey] = key
    _.o2map ht, (rows, keystr) ->
      [ keystr,
        { str: keystr, key: keys[keystr], table: ht[keystr] }
      ]



  # @param leftf, rightf methods to generate default rows if left or right arrays are empty
  #        defaults to: () -> new data.Row(new data.Schema)
  @arrayjoinIterator: (left, right, jointype, leftf=null, rightf=null) ->
    class Iter
      constructor: (@left, @right) ->
        @idx1 = 0
        @idx2 = 0

      reset: ->
        @idx1 = 0
        @idx2 = 0

      next: ->
        throw Error("iterator has no more elements") unless @hasNext()
        r1 = @left[@idx1]
        r2 = @right[@idx2]
        @idx2 += 1
        r1.clone().merge r2

      hasNext: ->
        while @idx1 < @left.length and @idx2 >= @right.length
          @idx2 = 0
          @idx1 += 1
        @idx1 < @left.length

      close: ->
        @left = @right = null

    left ?= []
    right ?= []
    defaultf = -> new data.Row(new data.Schema)
    leftf ?= defaultf
    rightf ?= defaultf

    switch jointype
      when "left"
        right = [rightf()] if right.length == 0
          
      when "right"
        left = [leftf()] if left.length == 0
          
      when "outer"
        left = [rightf()] if left.length == 0
        right = [rightf()] if right.length == 0
          
    new Iter left, right

