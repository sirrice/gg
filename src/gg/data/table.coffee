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

  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/
  @log = gg.util.Log.logger @ggpackage, "Table"

  @isEvalJS: (s) ->@reEvalJS.test s
  @isVariable: (s) -> @reVariable.test s
  @isNestedAttr: (s) -> @reNestedAttr.test s


  type: (colname) ->
      val = @get(0, colname)
      if val? then typeof val else 'unknown'

  nrows: -> throw "not implemented"
  ncols: -> throw "not implemented"
  # XXX: define return value.  currently Array<String>
  colNames: -> throw "not implemented"
  contains: (colName) -> colName in @colNames()

  @merge: (tables) -> gg.data.RowTable.merge tables

  each: (f, n=null) ->
    n = @nrows() unless n?
    _.map _.range(n), (i) => f @get(i), i

  # XXX: destructive!
  # updates column values in place
  # @param {Function or map} fOrName
  #        must specify colName if fOrMap is a Function
  #        otherwise, fOrMap is a mapping from colName --> (old val)->new val
  # @param {String} colName
  #        is specified if fOrName is a function, otherwise ignored
  map: (fOrMap, colName=null) -> throw Error("not implemented")
  clone: -> @cloneDeep()
  cloneShallow: -> throw "not implemented"
  cloneDeep: -> throw "not implemented"
  merge: (table)-> throw "not implemented"
  split: (gbfunc)-> throw "not implemented"
  transform: (colname, func)-> throw "not implemented"
  filter: (f) -> throw Error("not implemented")
  addConstColumn: (name, val, type=null) -> throw "not implemented"
  addColumn: (name, vals, type=null) -> throw "not implemented"
  addRows: (rows) -> _.each rows, (row) => @addRow row
  addRow: (row) -> throw "not implemented"
  get: (row, col=null)-> throw "not implemented"
  # because we may have column stores
  asArray: -> throw "not implemented"

  # Partition table on a set of table columns
  # Removes those columns from each partition's tuples
  partition: (cols) ->
    cols = _.flatten [cols]
    cols = _.filter cols, (col) => @schema.contains col

    keys = {}
    groups = {}
    @each (row) ->
      key = _.map cols, (col) -> row.get col
      jsonKey = JSON.stringify key
      groups[jsonKey] = [] unless jsonKey of groups
      groups[jsonKey].push row
      keys[jsonKey] = key

    ret = []
    schema = @schema.clone()
    _.each cols, (col) -> schema.rmColumn col
    _.each groups, (rows, jsonKey) ->
      _.each rows, (row) -> row.rmColumns cols
      partition = new gg.data.RowTable schema, rows
      ret.push {key: keys[jsonKey], table: partition}
    ret





