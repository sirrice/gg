# Stores data as an array of values + schema
class data.Row
  @ggpackage = "data.Row"

  # @param data [ value,... ]
  # @param schema 
  constructor: (@schema, @data=null) ->
    unless @schema?
      throw Error "Row needs a schema"
    
    @data ?= _.times @schema.ncols(), () -> null
    unless @data.length == @schema.ncols()
      console.log "[W] Row: ncols in row != schema  #{@data.length} != #{@schema.ncols()}"

  cols: -> @schema.cols
  has: (col, type=null) -> @schema.has col, type
  contains: (col, type=null) -> @schema.has col, type
  get: (col) -> @data[@schema.index(col)]
  set: (col, v) -> @data[@schema.index(col)] = v
  project: (cols) ->
    if _.isType cols, data.Schema
      schema = cols
      cols = schema.cols
    else
      cols = _.flatten [cols]
      schema = @schema.project cols
    rowData = _.map cols, (col) => @get col
    new data.Row schema, rowData

  # This is not performant within a tight loop because it infers the 
  # merged schema
  #
  # XXX: assumes null value means col value not set. e.g., 
  #      {x: 1}.merge({x:null}) returns {x: 1}
  #
  # @param cols columns to merge into this row.  if null, merges all
  merge: (row, cols=null) ->
    unless _.isType row, data.Row
      throw Error "can't merge non row"
    cols ?= row.schema.cols
    schema = @schema.clone()
    schema.merge row.schema
    ret = new data.Row schema
    for col in @schema.cols
      ret.set col, @get(col)
    for col in cols
      v = row.get(col)
      ret.set col, v if v?
        
    ret

  clone: ->
    rowData = _.map @data, (v) ->
      if v? and v.clone?
        v.clone()
      else
        v
    new data.Row @schema, rowData


  toJSON: -> _.o2map @schema.cols, (col) => [col, @get col]
  raw: -> @toJSON()
  toString: -> JSON.stringify(@toJSON())

  # turns an { } object into a data.Row
  @toRow: (o, schema=null) ->
    return o if _.isType o, data.Row

    unless schema?
      schema = new data.Schema 
      for k,v of o
        schema.addColumn k, data.Schema.type(v)

    rowData = []
    for col in schema.cols
      idx = schema.index col
      rowData[idx] = o[col]
    new data.Row schema, rowData



