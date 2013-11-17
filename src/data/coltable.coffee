#<< data/table

# Stores table in columnar format
class data.ColTable extends data.Table
  @ggpackage = "data.ColTable"


  constructor: (@schema, @colDatas=null) ->
    @colDatas ?= _.times @schema.ncols(), ()->[]
    @log = data.Table.log

  nrows: -> 
    if @colDatas.length == 0 then 0 else @colDatas[0].length
  ncols: -> @colDatas.length

  iterator: ->
    class Iter
      constructor: (@table) ->
        @schema = @table.schema
        @nrows = @table.nrows()
        @idx = 0
      reset: -> @idx = 0
      next: ->
        throw Error("no more elements.  idx=#{@idx}") unless @hasNext()
        @idx += 1
        rowData = _.map @colDatas, (cd) -> cd[@idx-1]
        new data.Row @schema, rowData
      hasNext: -> @idx < @nrows
      close: -> @table = @schema = null
    new Iter @

  # more efficient version of each, allocates single
  # data.Row object for entire iteration and minimizes 
  # copies
  # @param f functiton to run.  takes data.Row, index as input
  # @param n number of rows
  fastEach: (f, n=null) ->
    rowidx = 0
    nrows = @nrows()
    data = _.times @ncols(), () -> null
    row = new data.Row @schema, data
    ret = []
    while rowidx < nrows
      for col, colidx in @colDatas
        data[colidx] = col[rowidx]
      ret.push f(row, rowidx)
      rowidx += 1
      break if n? and rowidx >= n
    ret

  # Adds array, {}, or Row object as a row in this table
  #
  # @param raw { } object or a gg.data.Row
  # @param pad if argument is an array of value, should we pad the end with nulls
  #        if not enough values
  # @return self
  addRow: (row, pad=no) ->
    unless row?
      throw Error "adding null row"

    if _.isArray row
      unless row.length == @schema.ncols()
        if row.length > @schema.ncols() or not pad
          throw Error "row len wrong: #{row.length} != #{@schema.length}"

        for idx in _.range(@schema.ncols())
          if idx <= row.length
            @colDatas[idx].push row[idx]
          else
            @colDatas[idx].push null

    else if _.isType row, data.Row
      for col, idx in @cols()
        @colDatas[@schema.index col].push row.get(col)
    else if _.isObject row
      for col, idx in @cols()
        @colDatas[@schema.index col].push row[col]
    else
      throw Error "row type(#{row.constructor.name}) not supported" 
    @




  #
  # Static Instantiation Methods
  #

  serialize: ->
    colDatas = _.map @colDatas, (cd) ->
      _.map cd, _.toJSON
    JSON.stringify
      data: JSON.stringify colDatas
      schema: JSON.stringify(@schema.toJSON())
      type: 'col'

  @deserialize: (json) ->
    colDatas = JSON.parse json.data
    colDatas = _.map colDatas, (cd) ->
      _.map cd, _.fromJSON
    schema = data.Schema.fromJSON JSON.parse(json.schema)
    t = new data.ColTable schema
    t.colDatas = colDatas
    t

  @fromArray: (rows, schema=null) ->
    schema ?= data.Schema.infer rows
    cols = _.times schema.ncols(), () -> []
    if rows? and _.isType(rows[0], data.Row)
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
    new data.ColTable schema, cols

  @fromJSON: (json) ->
    schema = data.Schema.fromJSON json.schema
    t = new data.ColTable schema
    raws = _.fromJSON json.data
    for raw in raws
      t.addRow raw
    t

