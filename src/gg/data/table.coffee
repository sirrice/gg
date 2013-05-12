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
  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/

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
    _.each _.range(n), (i) => f @get(i), i

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
  addRow: (row) -> throw "not implemented"
  get: (row, col=null)-> throw "not implemented"
  # because we may have column stores
  asArray: -> throw "not implemented"

  @inferSchemaFromObjs: (rows) ->
    schema = new gg.data.Schema
    row = if rows.length > 0 then rows[0] else {}
    row = row.raw() if _.isSubclass row, gg.data.Row
    #console.log row
    _.each row, (v,k) =>
      type = gg.data.Schema.type v
      vtype = type.type
      vschema =  type.schema
      #console.log "gg.Table.inferSchema #{k}: #{vtype}"

      type = @findOrdinals rows, k, type
      schema.addColumn k, type.type, type.schema
    schema

  @findOrdinals: (rows, key, type) ->
    switch type.type
      when gg.data.Schema.numeric
        vals = _.map rows, (row) ->
          if _.isSubclass row, gg.data.Row
            row.get key
          else
            row[key]
        #console.log "isOrdinal (val): #{key}\t#{vals[0...20]}"
        #if gg.data.Table.isOrdinal vals
        #  type.type = gg.data.Schema.ordinal

      when gg.data.Schema.array, gg.data.Schema.nested
        schema = new gg.data.Schema
        schema.addColumn key, type.type, type.schema
        #console.log "isOrdinal schema: #{schema.toString()}\t#{schema.attrs()}"

        _.each schema.attrs(), (attr) ->
          if schema.isNumeric attr
            vals = _.map rows, (row) ->
              row = row.raw() if _.isSubclass row, gg.data.Row
              schema.extract row, attr
            vals = _.flatten vals
            #console.log "isOrdinal (arr): #{key}.#{attr}\t#{JSON.stringify vals[0...20]}"
            #console.log rows[0]

            if gg.data.Table.isOrdinal vals
              type.schema.setType attr, gg.data.Schema.ordinal
    type





  @isOrdinal: (vals) ->
    counter = {}
    for v in vals
      counter[v] = true
      if _.size(counter) > 10
        break
    _.size(counter) < 5










