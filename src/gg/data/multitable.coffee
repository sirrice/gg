#<< gg/data/rowtable
#<< gg/data/coltable

class gg.data.MultiTable extends gg.data.Table
  @ggpackage = "gg.data.MultiTable"

  constructor: (@schema, @tables=[]) ->
    @log = gg.data.Table.log
    @tables = _.compact @tables
    unless @schema?
      if @tables.length > 0
        @schema = gg.data.Schema.merge _.map(@tables, (t) -> t.schema)
      else
        @schema = new gg.data.Schema()

  nrows: -> _.sum @tables, (t) -> t.nrows()
  klass: -> 
    if @tables.length > 0
      @tables[0].klass()
    else
      gg.data.ColTable

  cloneShallow: ->
    ts = _.map @tables, (t) -> t.cloneShallow()
    new gg.data.MultiTable @schema.clone(), ts

  cloneDeep: ->
    ts = _.map @tables, (t) -> t.cloneDeep()
    new gg.data.MultiTable @schema.clone(), ts

  # this should really be a project
  setColumn: (col, val, type=null) ->
    tables = _.map @tables, (t) -> t.setColumn col, val, type
    new gg.data.MultiTable null, tables

  addColumn: (col, vals, type=null, overwrite=no) ->
    if vals.length != @nrows()
      throw Error "values not same length as table: #{vals.length} != #{@nrows()}"

    offset = 0
    tables = _.map @tables, (t) ->
      subvals = vals[offset...offset+t.nrows()]
      t.addColumn col, subvals, type, overwrite
      offset += t.nrows()
      t
    new gg.data.MultiTable null, tables

  rmColumn: (col) ->
    tables = _.map @tables, (t) -> t.rmColumn col
    new gg.data.MultiTable null, tables

  addRow: (row) ->
    row = gg.data.Row.toRow row
    if @tables.length == 0
      @tables.push new gg.data.RowTable(row.schema.clone())

    _.last(@tables).addRow row
    @

  get: (idx, col=null) ->
    for t, tidx in @tables
      if idx < t.nrows()
        return t.get idx, col
      idx -= t.nrows()

  _getColumn: (col) ->
    ret = []
    for t in @tables
      ret.push.apply ret, t._getColumn(col)
    ret

  raw: ->
    ret = []
    for t in @tables
      ret.push.apply ret, t.raw()
    ret

  @fromJSON: (json) ->
    gg.data.RowTable.fromJSON json




