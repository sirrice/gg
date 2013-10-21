#<< gg/data/schema

class gg.data.Transform

  # Creates a table that's cross product of the attrs
  # @param cols { attr1: [ values], ... }
  @cross: (cols, tabletype=null) ->
    rows = @cross_ cols
    return gg.data.Table.fromArray rows, null, tabletype

  @cross_: (cols, tabletype=null) ->
    if _.size(cols) == 0
      return [{}]
    rows = []
    col = _.first _.keys cols
    data = cols[col]
    cols = _.omit cols, col
    for v, idx in data
      for subrow in @cross_ cols
        row = {}
        row[col] = v
        _.extend row, subrow
        rows.push row
    return rows


  @sort: (table, cmp) ->
    rows = table.each (row) -> row
    rows.sort cmp

    klass = table.klass()
    newtable = new klass table.schema
    _.each rows, (row) -> newtable.addRow row
    newtable

  @sortOn: (table, cols, reverse=no) ->
    cols = _.flatten [cols]
    getval = (row) -> _.map cols, (col) -> row.get(col)
    reverse = if reverse then -1 else 1
    cmp = (r1, r2) ->
      for col in cols
        continue unless r1.has(col) and r2.has(col)
        if r1.get(col) > r2.get(col)
          return 1 * reverse
        if r1.get(col) < r2.get(col)
          return -1 * reverse
      return 0
    

  # Interal method to build hash tables based on equality of columns
  # @param cols columns to use for equality test
  # @return [ht, keys]  where
  #   ht = JSON.stringify(key) -> rows
  #   keys: JSON.stringify(key) -> key
  @buildHT: (t, cols) ->
    getkey = (row) -> _.map cols, (col) -> row.get(col)
    ht = {}
    keys = {}
    iter = t.iterator()
    while iter.hasNext()
      row = iter.next()
      key = getkey row
      strkey = JSON.stringify key
      # XXX: may need to use toJSON on key
      ht[strkey] = [] unless strkey of ht
      ht[strkey].push row
      keys[strkey] = key
    iter.close()
    [ht, keys]


  # Horizontally split table using an arbitrary splitting function
  # (preserves all existing columns)
  @split: (table, splitcols) ->
    splitcols = _.flatten [splitcols]
    klass = table.klass()
    [ht, keys] = @buildHT table, splitcols
    _.map ht, (rows, k) -> 
      {
        key: keys[k]
        table: klass.fromArray rows, table.schema.clone()
      }

  # alias for @split
  @partition: (args...) -> @split args...
      
  # create new table containing the (exact same)
  # rows from current table, with rows failing the filter
  # test not present
  @filter: (table, f) ->
    klass = table.klass()
    newt = new klass table.schema.clone()
    table.each (row, idx) ->
      newt.addRow row if f(row, idx)
    newt

  # Project, but remove columns instead of projecting them
  @exclude: (table, cols) ->
    cols = _.flatten [cols]
    keep = _.reject table.schema.cols, (col) -> col in cols
    mapping = _map keep, (col) ->
      f = (val) -> val
      [col, f, table.schema.type(col)]
    @mapCols table, mapping

  # add @param mapping to schema
  #
  # @param mapping is list of triples
  #
  #  [ [key, f, type ] ]
  #
  @transform: (table, mapping) ->
    lookup = _.o2map mapping, ([col, f, type]) -> [col, f]
    for col in table.schema.cols
      unless col of lookup
        f = ((col) -> (row) -> row.get(col))(col)
        mapping.push [col, f, table.schema.type(col)]
    @map table, mapping

  # single column transformations
  # mapping is of the form
  #
  #   [
  #     [ key, f, type ]
  #   ]
  #
  # where f: (colval, idx) -> newval
  #
  @mapCols: (table, mapping) ->
    mapping = _.map _.compact(mapping), ([col, f, type]) ->
      type ?= f.type or gg.data.Schema.unknown
      [col, f, type]

    schema = table.schema.clone()
    schema = schema.exclude _.map(mapping, ([c,f,t])->c)
    newSchema = new gg.data.Schema()
    for [col, f, type] in mapping
      newSchema.addColumn col, type
    schema.merge newSchema

    rows = table.each (row, idx) ->
      raw = row.raw()
      _.map mapping, ([col, f, type]) ->
        v = f raw[col], idx
        if idx <= 10 and schema.type(col) == gg.data.Schema.unknown
          schema.setType col, gg.data.Schema.type(v)
        raw[col] = v
      raw

    table.klass().fromArray rows, schema


  # mapping is of the form
  #
  #   [ [key, f, type] ]
  #
  # where f: (row, idx) -> newval
  #
  @map: (table, mapping) ->
    mapping = _.map _.compact(mapping), ([col, f, type]) ->
      type ?= f.type or gg.data.Schema.unknown
      [col, f, type]

    schema = new gg.data.Schema()
    for [col, f, type] in mapping
      schema.addColumn col, type

    iter = table.iterator()
    idx = 0
    newrows = []
    while iter.hasNext()
      row = iter.next()
      o = _.o2map mapping, ([col, f, type], idx) ->
        v = f row, idx
        if idx <= 10
          if schema.type(col) == gg.data.Schema.unknown
            schema.setType col, gg.data.Schema.type(v)
        [col, v]
      idx += 1
      newrows.push o
    table.klass().fromArray newrows, schema
        

    
  # Equijoin + partition on join columns
  # @return Array[{key:, table: pairtable}]
  @partitionJoin: (t1, t2, joincols, type='outer') ->
    joincols = _.flatten [joincols]
    ###
    unless t1.hasCols(joincols)
      throw Error "left table doesn't have all columns: #{joincols} not in #{t1.schema.toString()}"
    unless t2.hasCols(keys)
      throw Error "right table doesn't have all columns: #{joincols} not in #{t2.schema.toString()}"
    ###

    [ht1, keys1] = @buildHT t1, joincols
    [ht2, keys2] = @buildHT t2, joincols
    schema1 = t1.schema
    schema2 = t2.schema

    strkeys = switch type
      when 'inner'
        _.intersection _.keys(ht1), _.keys(ht2)
      when 'left'
        _.keys(ht1)
      when 'right'
        _.keys(ht2)
      when 'outer'
        _.uniq _.flatten [_.keys(ht1), _.keys(ht2)]
      else
        throw Error "invalid join type #{type}"

    ret = []
    for strkey in strkeys
      rows1 = ht1[strkey]
      rows2 = ht2[strkey]
      left = t1.klass().fromArray rows1, schema1.clone()
      right = t2.klass().fromArray rows2, schema2.clone()
      table = new gg.data.PairTable left, right
      key = if strkey of keys1 then keys1[strkey] else keys2[strkey]
      ret.push { key: key, table: table }
    ret



    

