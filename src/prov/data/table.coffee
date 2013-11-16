#<< gg/data/schema
#<< gg/data/row


#
# The data model consists of a list of tuples (rows)
#
# Each tuple (row) contains a list of columns
# The data types include
# 1) atomic datatypes -- numeric, string, datetime
# 2) function datatype
# 3) object data type -- tuple knows how to inspect into it
# 3) array data type of mappings -- not inspected
#
# Attribute resolution
# 1) check for attributes containing atomic data types
# 2) check each column that is of type object
#
# Methods that start with "_" are update in place and return the same table
#


class gg.data.Table
  @ggpackage = "gg.data.Table"
  @log = gg.util.Log.logger @ggpackage, "Table"

  # @param f functiton to run.  takes gg.data.Row, index as input
  # @param n number of rows
  each: (f, n=null) ->
    iter = @iterator()
    idx = 0
    ret = []
    while iter.hasNext()
      ret.push f(iter.next(), idx)
      idx +=1 
      break if n? and idx >= n
    iter.close()
    ret

  # read-only each 
  fastEach: (f, n) -> @each f, n

  iterator: -> throw Error("iterator not implemented")

  partition: (cols) ->
    partitions = gg.data.Transform.split @, cols
    _.map partitions, (p) -> p['table']


  has: (col, type) -> @contains col, type
  contains: (col, type) -> @schema.has col, type
  hasCols: (cols, types=null) ->
    _.all cols, (col, idx) =>
      type = null
      type = types[idx] if types? and types.length > idx
      @has col, type
  cols: -> @schema.cols

  ncols: -> @schema.ncols()
  nrows: -> 
    i = 0
    @each (row) -> i += 1
    i

  rows: -> @each (row) -> row
  getRows: -> @each (row) -> row
  raw: -> throw "not implemented"
  stats: -> throw "not implemented"
  klass: -> gg.data.ColTable

  # This is the only method other than addCol that changes the data
  addRow: (row) -> throw "not implemented"

  toJSON: ->
    schema: @schema.toJSON()
    data: _.toJSON @raw()
    klass: @klass().name

  @fromJSON: (json) ->
    klass = @type2class(json.klass)
    klass ?= gg.data.ColTable
    klass.fromJSON json

  toString: ->
    JSON.stringify @raw()


  @type2class: (tabletype="row") ->
    switch tabletype
      when "row", "RowTable"
        gg.data.RowTable
      when "col", "ColTable"
        gg.data.ColTable
      else
        null

  @deserialize: (str) ->
    json = JSON.parse str
    switch json.type
      when 'multi'
        gg.data.MultiTable.deserialize json
      when 'col'
        gg.data.ColTable.deserialize json
      when 'row'
        gg.data.RowTable.deserialize json
      else
        throw Error "can't deserialize data of type: #{json.type}"


  # Tries to infer a schema for a list of objects
  #
  # @param rows [ { attr: val, .. } ]
  @fromArray: (rows, schema=null, tabletype="row") ->
    klass = @type2class tabletype
    unless klass?
      throw Error "#{tabletype} doesnt have a class"

    klass.fromArray rows, schema

  @merge: (tables, tabletype="row") ->
    klass = @type2class tabletype
    if tables.length is 0
      schema = new gg.data.Schema()
      new klass schema
    else
      schema = gg.data.Schema.merge _.map(tables, (t) -> t.schema)
      table = new klass schema
      for t in tables
        t.each (row) -> table.addRow row.raw()
      table



  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/

  @isEvalJS: (s) ->@reEvalJS.test s
  @isVariable: (s) -> @reVariable.test s
  @isNestedAttr: (s) -> @reNestedAttr.test s
