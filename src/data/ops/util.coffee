

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

