#<< gg/data/schema

class gg.data.Transform

  @sort: (table, cmp) ->
    rows = table.each (row) -> row
    rows.sort cmp

    klass = table.constructor
    newtable = new klass table.schema
    _.each rows, (row) -> newtable.addRow row
    newtable

  # Horizontally split table using an arbitrary splitting function
  # (preserves all existing columns)
  @split: (table, gbfunc) ->
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
      
  # create new table containing the (exactly same)
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
        
