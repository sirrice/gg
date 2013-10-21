#<< gg/data/table

# Stores table in columnar format
class gg.data.ColTable extends gg.data.Table
  @ggpackage = "gg.data.ColTable"


  constructor: (@schema, @colDatas=null) ->
    @colDatas ?= _.times @schema.ncols(), ()->[]
    @log = gg.data.Table.log

  nrows: -> 
    if @colDatas.length == 0 then 0 else @colDatas[0].length
  ncols: -> @colDatas.length

  cloneShallow: ->
    cols = _.map @colDatas, (col) -> _.clone col
    new gg.data.ColTable @schema.clone(), cols

  cloneDeep: -> @cloneShallow()

  # internal method
  _addColumn: (col, vals) ->
    unless @has col
      throw Error("col should be in the schema: #{col}")
    @colDatas[@schema.index col] = vals
    @

  rmColumn: (col) ->
    return @ unless @has col
    idx = @schema.index col
    @colDatas.splice idx, 1
    @schema = @schema.exclude col
    @

  # Adds array, {}, or Row object as a row in this table
  #
  # @param raw { } object or a gg.data.Row
  # @param pad if argument is an array of value, should we pad the end with nulls
  #        if not enough values
  # @return self
  addRow: (raw, pad=no) ->
    unless row?
      throw Error "adding null row"

    if _.isArray raw
      unless raw.length == @schema.ncols()
        if raw.length > @schema.ncols() or not pad
          throw Error "row len wrong: #{row.length} != #{@schema.length}"

        for idx in _.range(@schema.ncols())
          if idx <= raw.length
            @colDatas[idx].push raw[idx]
          else
            @colDatas[idx].push null

    else if _.isType row, gg.data.Row
      for col, idx in @colDatas()
        @colDatas[@schema.index col].push row.get(col)
    else if _.isObject row
      for col, idx in @colDatas()
        @colDatas[@schema.index col].push row[col]
    else
      throw Error "row type(#{row.constructor.name}) not supported" 
    @

  get: (idx, col=null) ->
    if col?
      if @schema.has col
        @colDatas[@schema.index col][idx]
      else
        throw Error "col #{col} not in schema: #{@schema.toString()}"
    else
      rowdata = _.map @colDatas, (coldata) -> coldata[idx]
      new gg.data.Row @schema, rowdata

  _getColumn: (col) -> 
    @colDatas[@schema.index col]

  raw: ->
    _.times @nrows(), (i) => 
      _.o2map @schema.cols, (col) => [col, @colDatas[@schema.index(col)][i]]

  @fromArray: (rows, schema=null) ->
    schema ?= gg.data.Schema.infer rows
    cols = _.times schema.ncols(), () -> []
    if rows? and _.isType(rows[0], gg.data.Row)
      for row in rows
        for col in schema.cols
          idx = schema.index col
          cols[idx].push row.get(col)
    else
      for row in rows
        for col in schema.cols
          if col of row
            cols[schema.index col].push row[col]
          else
            cols[schema.index col].push null
    new gg.data.ColTable schema, cols

  @fromJSON: (json) ->
    schema = gg.data.Schema.fromJSON json.schema
    t = new gg.data.ColTable schema
    for raw in json.data
      t.addRow raw
    t

