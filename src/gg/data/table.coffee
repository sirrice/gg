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


class gg.data.Table
  @ggpackage = "gg.data.Table"
  @log = gg.util.Log.logger @ggpackage, "Table"

  @type2class: (tabletype="row") ->
    switch tabletype
      when "row"
        gg.data.RowTable
      when "col"
        gg.data.ColTable
      else
        null

  # Tries to infer a schema for a list of objects
  #
  # @param rows [ { attr: val, .. } ]
  @fromArray: (rows, tabletype="row") ->
    klass = @type2class tabletype
    unless klass?
      throw Error "#{tabletype} doesnt have a class"

    klass.fromArray rows

  @merge: (tables, tabletype="row") ->
    klass = @type2class tabletype
    if tables.length is 0
      schema = new gg.data.Schema()
      new klass schema
    else
      table = new klass tables[0].schema
      for t in tables
        t.each (row) -> table.add row
      table


  # map(rows, f)
  #
  # @param f functiton to run
  # @param n number of rows
  each: (f, n=null) ->
    n = @nrows() unless n?
    n = Math.min @nrows(), n
    _.times n, (i) => f @get(i), i


  asArray: ->
    ret = []
    @each (row) -> ret.push row.toJSON()
    ret

  has: (col, type) -> @contains col, type
  contains: (col, type) -> @schema.has col, type
  ncols: -> @schema.ncols()
  cols: -> @schema.cols

  schema: -> throw "not implemented"
  iterator: -> throw "not implemented"
  stats: -> throw "not implemented"

  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/

  @isEvalJS: (s) ->@reEvalJS.test s
  @isVariable: (s) -> @reVariable.test s
  @isNestedAttr: (s) -> @reNestedAttr.test s


  toJSON: ->
    schema: @schema.toJSON()
    data: @raw()


