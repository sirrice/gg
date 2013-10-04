#<< gg/util/log
#<< gg/data/schema

# Stores data as an array of values + schema
class gg.data.Row
  @ggpackage = "gg.data.Row"
  @log = gg.util.Log.logger @ggpackage, "row"

  # @param data [ value,... ]
  # @param schema 
  constructor: (@data, @schema) ->
    @log = gg.data.Row.log
    unless @schema?
      throw Error "Row needs a schema"
    unless @data.length == @schema.ncols()
      throw Error "ncols in row != schema  #{@data.length} != #{@schema.ncols()}"

  cols: -> @schema.cols
  has: (col, type=null) -> @schema.has col, type
  contains: (col, type=null) -> @schema.has col, type
  get: (col) -> @data[@schema.index(col)]
  set: (col, v) -> @data[@schema.index(col)] = v
  project: (cols) ->
    schema = @schema.project cols
    data = _.map cols, (col) => @get col
    new gg.data.Row data, schema

  merge: (row) ->
    unless _.isType row, gg.data.Row
      throw Error "can't merge non row"
    cols = _.reject(schema.cols, (col) => @col.has col)
    vals = _.map cols, (col) -> row.get col
    @data.push.apply @data, vals
    @schema.merge row.schema
    @

  clone: ->
    data = _.clone @data
    new gg.data.Row data, @schema

  toString: ->
    o = _.o2map @schema.cols, (col) => [col, @get col]
    JSON.stringify o

  toJSON: ->
    _.o2map @schema.cols, (col) => [col, @get col]

  raw: -> @toJSON()

  @toRow: (o, schema=null) ->
    return o if _.isType o, gg.data.Row

    unless schema?
      schema = new gg.data.Schema 
      for k,v of o
        schema.addColumn k, gg.data.Schema.type(v)

    data = []
    for col in schema.cols
      idx = schema.index col
      data[idx] = o[col]
    new gg.data.Row data, schema



