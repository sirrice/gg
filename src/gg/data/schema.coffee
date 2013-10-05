#<< gg/util/log

class gg.data.Schema
  @ggpackage = "gg.data.Schema"
  @log = gg.util.Log.logger @ggpackage, "Schema"

  @ordinal = 0
  @numeric = 2
  @date = 3
  @object = 4
  @env = 5    # environment variable
  @unknown = -1

  constructor: (@cols=[], @types=[]) ->
    if @cols.length != @types.length
      throw Error("len of cols != types #{@cols.length} != #{@types.length}")

    @log = gg.data.Schema.log
    @col2idx = {}
    _.each @cols, (col, idx) =>
      @col2idx[col] = idx

  ncols: -> @cols.length
  index: (col) -> @col2idx[col]
  isOrdinal: (col) -> @type(col) is gg.data.Schema.ordinal
  isNumeric: (col) -> @type(col) is gg.data.Schema.numeric
  isDate: (col) -> @type(col) is gg.data.Schema.date
  isObject: (col) -> @type(col) is gg.data.Schema.object
  isUnknown: (col) -> @type(col) is gg.data.Schema.unknown

  addColumn: (col, type=gg.data.Schema.unknown) ->
    unless @has col
      @cols.push(col)
      @types.push type
      @col2idx[col] = @cols.length-1
      yes
    else
      no

  setType: (col, type) ->
    if @type(col) is gg.data.Schema.unknown
      @types[@index col] = type
    else
      throw Error "can't update #{col} because type not unknown: #{@type col}"

  project: (cols) ->
    types = _.map cols, (col) => 
      unless @has col
        throw Error("col #{col} not in schema")
      @types[@index col]
    new gg.data.Schema(cols, types)

  type: (col) -> @types[@index col]

  contains: (col, type=null) -> @has col, type
  has: (col, type=null) -> 
    if type?
      idx = @index col
      (col of @col2idx) and @types[idx] == type
    else
      col of @col2idx

  @merge: (schema1, schema2) ->
    schema = schema1.clone()
    for [col, type] in _.zip(schema.cols, schema.types)
      schema.addColumn col, type
    schema

  # @return type object { type: , schema:  }
  @type: (v) ->
    if _.isDate v
      gg.data.Schema.date
    else if _.isObject v
      gg.data.Schema.object
    else if _.isNumber v
      gg.data.Schema.numeric
    else
      gg.data.Schema.ordinal 

  # @param rows [ {col: val, ..} ]
  @infer: (rows) ->
    schema = new gg.data.Schema
    return schema unless rows? and rows.length > 0

    for row in rows[0...50]
      if _.isType row, gg.data.Row
        row.merge(row.schema) 
      else
        for k, v of row
          schema.addColumn k, @type(v)
    schema

  clone: -> @project _.clone(@cols)
  toString: -> JSON.stringify _.zip(@cols, @types)
  toSimpleString: -> 
    _.map(_.zip(@cols, @types), ([col, type]) -> "#{col}(#{type})").join " "

  @fromJSON: (json) -> 
    new gg.data.Schema _.keys(json), _.values(json)

  toJSON: ->
    ret = {}
    for [col, type] in _.zip(@cols, @types)
      ret[col] = type
    ret


