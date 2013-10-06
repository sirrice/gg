#<< gg/data/schema

class gg.data.Transform

  @sort: (table, cmp) ->
    rows = table.each (row) -> row
    rows.sort cmp

    klass = table.constructor
    newtable = new klass table.schema
    _.each rows, (row) -> newtable.addRow row
    newtable

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
    ht = @buildHT table, splitcols
    _.map _.values(ht), (partition) ->
      newt = new table.constructor table.schema.clone()
      for row in partition
        newt.addRow row
      newt

    ###
    # TODO: special case for this
    if _.isString gbfunc
      attr = gbfunc
      gbfunc = ((key) -> (row) -> row.get(key))(attr)

    klass = table.constructor
    keys = {}
    groups = {}
    table.each (row) ->
      key = gbfunc row
      jsonkey = JSON.stringify key
      unless jsonkey of groups
        groups[jsonkey] = new klass table.schema.clone()
        keys[jsonkey] = key
      groups[jsonkey].addRow row

    _.map groups, (newtable, jsonkey) ->
      { key: keys[jsonkey], table: newtable }
    ###
      
  # create new table containing the (exact same)
  # rows from current table, with rows failing the filter
  # test not present
  @filter: (table, f) ->
    newt = new table.constructor table.schema.clone()
    table.each (row, idx) ->
      newt.addRow row if f(row, idx)
    newt

  @transform: (table, mapping) ->
    schema = new gg.data.Schema
    for col in table.schema.cols
      unless col of mapping
        mapping[col] = (row) -> row.get col
    @map table, mapping

  @map: (table, mapping) ->
    rows = table.each (row, idx) ->
      _.o2map mapping, (f, k) ->
        v = try
          f row, idx
        catch err
          console.log row.raw()
          console.log f.toString()
          console.log err
          throw err
        [k, v]
    table.constructor.fromArray rows
        
    
  # Equijoin + partition on join columns
  # @return Array[pairtable]
  @partitionJoin: (t1, t2, joincols) ->
    unless t1.hasCols(joincols) and t2.hasCols(keys)
      throw Error
    ht1 = buildHT t1
    ht2 = buildHT t2
    keys = _.uniq _.flatten [_.keys(ht1), _.keys(ht2)]

    ret = []
    for key in keys
      rows1 = ht1[key]
      rows2 = ht2[key]
      left = t1.constructor.fromArray rows1, t1.schema.clone()
      right = t2.constructor.fromArray rows2, t2.schema.clone()
      ret.push new gg.data.PairTable(left, right)
    ret



    

