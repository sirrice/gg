class data.Schema
  @ggpackage = "data.Schema"

  @ordinal = 0
  @numeric = 2
  @date = 3
  @object = 4
  @svg = 5    # environment variable
  @container = 6
  @function = 7
  @table = 8
  @unknown = -1


  constructor: (@cols=[], @types=[], @defaults={}) ->
    if @cols.length != @types.length
      throw Error("len of cols != types #{@cols.length} != #{@types.length}")

    @col2idx = {}
    _.each @cols, (col, idx) =>
      @col2idx[col] = idx

  ncols: -> @cols.length
  index: (col) -> @col2idx[col]

  isOrdinal: (col) -> @type(col) is data.Schema.ordinal
  isNumeric: (col) -> @type(col) is data.Schema.numeric
  isDate: (col) -> @type(col) is data.Schema.date
  isObject: (col) -> @type(col) is data.Schema.object
  isUnknown: (col) -> @type(col) is data.Schema.unknown
  default: (col) -> @defaults[col]

  addColumn: (col, type=data.Schema.unknown) ->
    unless @has col
      @cols.push(col)
      @types.push type
      @col2idx[col] = @cols.length-1
      yes
    else
      no

  setType: (col, type) ->
    return if type == @type(col)
    if @type(col) is data.Schema.unknown
      @types[@index col] = type
    else
      throw Error "can't update #{col} because type not unknown: #{@type col}"

  project: (cols) ->
    cols = _.compact _.flatten [cols]
    types = _.map cols, (col) => 
      unless @has col
        throw Error("col #{col} not in schema")
      @types[@index col]
    new data.Schema(cols, types)

  # removes col, preserves ordering
  exclude: (rm) ->
    rm = _.flatten [rm]
    idxs = _.map rm, (col) => @index col
    cols = []
    types = []
    for col in @cols
      if @index(col) not in idxs
        cols.push col
        types.push @type(col)

    new data.Schema cols, types

  type: (col) -> @types[@index col]

  contains: (col, type=null) -> @has col, type
  has: (col, type=null) -> 
    if type?
      idx = @index col
      (col of @col2idx) and @types[idx] == type
    else
      col of @col2idx

  merge: (other) ->
    return unless _.isType other, data.Schema
    for col in other.cols
      unless @has col
        @addColumn col, other.type(col)
    @

  equals: (schema) ->
    for col in @cols
      unless schema.has col, @type(col)
        return no
    for col in schema.cols
      unless @has col, schema.type(col)
        return no
    yes



  @merge: (schemas) ->
    schemas = _.flatten arguments
    schema = null
    for curschema in schemas
      unless schema?
        schema = curschema.clone()
      else
        for [col, type] in _.zip(curschema.cols, curschema.types)
          schema.addColumn col, type
    schema


  # @return type object { type: , schema:  }
  @type: (v) ->
    if _.isDate v
      data.Schema.date
    else if _.isObject v
      data.Schema.object
    else if _.isNumber v
      data.Schema.numeric
    else
      data.Schema.ordinal 

  # @param rows [ {col: val, ..} ]
  @infer: (rows) ->
    schema = new data.Schema
    return schema unless rows? and rows.length > 0

    for row in rows[0...50]
      if _.isType row, data.Row
        schema.merge(row.schema) 
      else
        for k, v of row
          schema.addColumn k, @type(v)
    schema

  @intersect: (s1, s2) ->
    ret = new data.Schema
    for col in s1.cols
      if s2.has col, s1.type(col)
        ret.addColumn col, s1.type(col)
    ret


  clone: -> @project _.clone(@cols)
  toString: -> JSON.stringify _.zip(@cols, @types)
  toSimpleString: -> 
    _.map(_.zip(@cols, @types), ([col, type]) -> "#{col}(#{type})").join " "

  @fromJSON: (json) -> 
    new data.Schema _.keys(json), _.values(json)

  toJSON: ->
    ret = {}
    for [col, type] in _.zip(@cols, @types)
      ret[col] = type
    ret


