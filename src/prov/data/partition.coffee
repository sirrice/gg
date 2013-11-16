class gg.data.Partition extends gg.data.Table

  constructor: (@table, @cols) ->
    @schema = @table.schema.project @cols
    @schema.addColumn '_val', gg.data.Schema.object

  iterator: ->
    class Iter
      constructor: (@schema, @table, @cols) ->
        @iter = @table.iterator()
        @idx = 0

      reset: -> 
        @iter.reset()
        @idx = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        row = new gg.data.Row @schema
        htrow = @ht[@idx]
        @idx += 1
        for col in @cols
          row.set col, htrow.key[col]
        row.set '_val', htrow.table
        row

      hasNext: -> 
        unless @ht?
          @ht = _.values(gg.data.Partition.buildHT @table, @cols)
        @idx < @ht.length

      close: -> 
        @table = null
        @iter.close()

    new Iter @schema, @table, @cols


  # Interal method to build hash tables based on equality of columns
  # @param cols columns to use for equality test
  # @return [ht, keys]  where
  #   ht = JSON.stringify(key) -> rows
  #   keys: JSON.stringify(key) -> key
  @buildHT: (t, cols) ->
    getkey = (row) -> _.map cols, (col) -> row.get(col)
    ht = {}
    keys = {}
    while t.hasNext()
      row = t.row()
      key = getkey row
      strkey = JSON.stringify key
      # XXX: may need to use toJSON on key
      ht[strkey] = [] unless strkey of ht
      ht[strkey].push row.raw()
      keys[strkey] = key
    _.o2map ht, (rows, keystr) ->
      [ keystr,
        { str: keystr, key: keys[keystr], table: ht[keystr] }
      ]


