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

    klass = table.constructor
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
  @buildHT: (t, cols) ->
    getkey = (row) -> _.map cols, (col) -> row.get(col)
    ht = {}
    iter = t.iterator()
    while iter.hasNext()
      row = iter.next()
      key = getkey row
      # XXX: may need to use toJSON on key
      ht[key] = [] unless key of ht
      ht[key].push row
    iter.close()
    ht


  # Horizontally split table using an arbitrary splitting function
  # (preserves all existing columns)
  @split: (table, splitcols) ->
    splitcols = _.flatten [splitcols]
    klass = table.constructor
    ht = @buildHT table, splitcols
    _.map ht, (rows, k) -> 
      {
        key: k
        table: klass.fromArray rows, table.schema.clone()
      }

  # alias for @split
  @partition: (args...) -> @split args...
      
  # create new table containing the (exact same)
  # rows from current table, with rows failing the filter
  # test not present
  @filter: (table, f) ->
    newt = new table.constructor table.schema.clone()
    table.each (row, idx) ->
      newt.addRow row if f(row, idx)
    newt

  # Project, but remove columns instead of projecting them
  @exclude: (table, cols) ->
    cols = _.flatten [cols]
    keep = _.reject table.schema.cols, (col) -> col in cols
    @map table, keep

  # add @param mapping to schema
  @transform: (table, mapping) ->
    schema = new gg.data.Schema
    for col in table.schema.cols
      unless col of mapping
        mapping[col] = ((col) -> (row) -> row.get col)(col)
    @map table, mapping

  # single column transformations
  # mapping is of the form
  #
  #   col: (colvalue) -> new value
  #
  @mapCols: (table, mapping) ->
    schema = new gg.data.Schema
    rows = table.each (row, idx) ->
      raw = row.raw()
      o = _.o2map mapping, (f, col) ->
        [col, f(raw[col], idx)]
      _.extend raw, o
      raw
    table.constructor.fromArray rows

  # return schema with ONLY mapping
  @map: (table, mapping) ->
    iter = table.iterator()
    idx = 0
    newrows = []
    while iter.hasNext()
      row = iter.next()
      o = _.o2map mapping, (f, k) ->
        [k, f(row, idx)]
      idx += 1
      newrows.push o
    table.constructor.fromArray newrows
        

    
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

    ht1 = @buildHT t1, joincols
    ht2 = @buildHT t2, joincols
    schema1 = t1.schema
    schema2 = t2.schema

    keys = switch type
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
    for key in keys
      rows1 = ht1[key]
      rows2 = ht2[key]
      left = t1.constructor.fromArray rows1, schema1.clone()
      right = t2.constructor.fromArray rows2, schema2.clone()
      table = new gg.data.PairTable left, right
      ret.push { key: key, table: table }
    ret



    
