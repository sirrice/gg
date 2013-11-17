#<< data/table

class data.ops.Partition extends data.Table

  constructor: (@table, @cols) ->
    @cols = _.flatten [@cols]
    @schema = @table.schema.project @cols
    @schema.addColumn 'table', data.Schema.table

  iterator: ->
    class Iter
      constructor: (@schema, @table, @cols) ->
        @idx = 0

      reset: -> 
        @idx = 0

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        row = new data.Row @schema
        htrow = @ht[@idx]
        @idx += 1
        for col, idx in @cols
          row.set col, htrow.key[idx]
        row.set 'table', htrow.table
        row

      hasNext: -> 
        unless @ht?
          @ht = _.values(data.ops.Partition.buildHT @table, @cols)
        @idx < @ht.length

      close: -> 
        @table = null

    new Iter @schema, @table, @cols


  # Interal method to build hash tables based on equality of columns
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


