#<< gg/data/table

# stores table as a list of arrays and a schema
class gg.data.RowTable extends gg.data.Table
  @ggpackage = "gg.data.RowTable"

  constructor: (@schema, rows=[]) ->
    throw Error("schema not present") unless @schema?
    rows ?= []
    @rows = []
    _.each rows, (row) => @addRow row
    @log = gg.data.Table.log


  nrows: -> @rows.length

  cloneShallow: ->
    rows = _.clone @rows
    t = new gg.data.RowTable @schema.clone()
    t.rows = rows
    t

  cloneDeep: ->
    rows = @rows.map (row) -> _.clone row
    t = new gg.data.RowTable @schema.clone()
    t.rows = rows
    t

  # this should really be a project
  addConstColumn: (col, val, type=null) ->
    if @has col
      throw Error "#{col} already in schema #{@schema.toString()}"

    type = gg.data.Schema.type(val) unless type?
    @schema.addColumn col, type
    idx = @schema.index col
    for row in @rows
      row[idx] = val
    @

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
    for row in @rows
      row[idx] = vals[idx]
    @

  rmColumn: (col) ->
    return @ unless @has col
    rmidx = @schema.index col
    for row in @rows
      row.splice rmidx, 1

    @schema = @schema.exclude col
    @


  # accepts an array of values (must conform with schema), {} objects, or a Row object
  addRow: (row, pad=no) ->
    unless row?
      throw Error "adding null row"

    if _.isArray(row)
      unless row.length == @schema.ncols()
        if row.length > @schema.ncols() or not pad
          throw Error "row len wrong: #{row.length} != #{@schema.length}"
        else
          for i in [0...(@schema.ncols()-row.length)]
            row.push null
    else if _.isType row, gg.data.Row
      arr = []
      for col in @schema.cols
        arr.push(row.get col)
      row = arr
    else if _.isObject row
      arr = []
      for col in @schema.cols
        arr.push(row[col])
      row = arr
    else
      throw Error "row type(#{row.constructor.name}) not array" 

    @rows.push row
    @

  # @return value if col is set, otherwise gg.data.Row object
  get: (idx, col=null) ->
    if idx >= 0 and idx < @nrows()
      if col?
        if @schema.has col
          @rows[idx][@schema.index col]
        else
          throw Error "col #{col} not in schema: #{@schema.toString()}"
      else
          new gg.data.Row @schema, @rows[idx]
    else
      null

  getCol: (col) -> @getColumn col
  getColumn: (col) ->
    unless @schema.has col
      throw Error "col #{col} not in schema #{@schema.toString()}"

    idx = @schema.index col
    _.map @rows, (row) -> row[idx]

  # return a list of {} objects
  raw: -> 
    _.map @rows, (r) => 
      o = {}
      for col in @schema.cols
        o[col] = r[@schema.index col]
      o

  # Infers a schema from inputs and returns a row table object
  # @param rows list of { } objects
  @fromArray: (rows, schema=null) ->
    schema ?= gg.data.Schema.infer rows
    if rows? and _.isType(rows[0], gg.data.Row)
      rows = _.map rows, (row) ->
        _.map schema.cols, (col) -> row.get(col)
    else
      rows = _.map rows, (o) ->
        _.map schema.cols, (col) -> o[col]
    new gg.data.RowTable schema, rows


  @fromJSON: (json) ->
    schemaJson = json.schema
    dataJson = json.data

    schema = gg.data.Schema.fromJSON schemaJson
    rows = []
    for raw in dataJson
      rows.push(gg.data.Row.toRow raw, schema)
    new gg.data.RowTable schema, rows




