#<< gg/data/table

class gg.data.RowTable extends gg.data.Table
  @ggpackage = "gg.data.RowTable"

  constructor: (@schema, rows=[]) ->
    throw Error("schema not present") unless @schema?
    @rows = []
    _.each rows, (row) => @addRow row
    @log = gg.data.Table.log


  nrows: -> @rows.length

  cloneShallow: ->
    rows = _.clone @rows
    new gg.data.RowTable @schema.clone(), rows

  cloneDeep: ->
    rows = @rows.map (row) => row.clone()
    new gg.data.RowTable @schema.clone(), rows

  # this should really be a project
  addConstColumn: (col, val, type=null) ->
    if @schema.has col
      throw Error "#{col} already exists in schema #{@schema.toString()}"

    type = gg.data.Schema.type(val) unless type?
    @schema.addColumn col, type
    @each (row) =>
      row.schema = @schema
      row.set(col, val)

  addColumn: (col, vals, type=null) ->
    if @schema.has col
      throw Error "#{col} already exists in schema #{@schema.toString()}"
    if vals.length != @nrows()
      throw Error "vals length != table length.  #{vals.length} != #{@nrows()}"

    unless type?
      type = if vals.length == 0 
        gg.data.Schema.unknown
      else
        gg.data.Schema.type vals[0]
    
    @schema.addColumn col, type
    idx = @schema.index col
    @each (row, idx) =>
      row.schema = @schema
      row.set col, vals[idx]
    @


  addRow: (row) ->
    @rows.push gg.data.Row.toRow(row, @schema)
    @

  get: (idx, col=null) ->
    if idx >= 0 and idx < @nrows()
      if col?
          @rows[idx].get col
      else
          @rows[idx]
    else
      null

  getCol: (col) -> @getColumn col
  getColumn: (col) ->
    ret = []
    @each (row) => ret.push row.get(col)
    ret

  raw: -> @each (row) -> row.raw()

  @fromArray: (rows) ->
    schema = gg.data.Schema.infer rows
    new gg.data.RowTable schema, rows


  @fromJSON: (json) ->
    schemaJson = json.schema
    dataJson = json.data

    schema = gg.data.Schema.fromJSON schemaJson
    rows = []
    for raw in dataJson
      rows.push(gg.data.Row.toRow raw, schema)
    new gg.data.RowTable schema, rows




