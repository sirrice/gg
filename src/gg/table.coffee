#<< gg/schema
#<< gg/row
# XXX: NEED SCHEMA SUPPORT


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


class gg.Table
  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/

  type: (colname) ->
      val = @get(0, colname)
      if val? then typeof val else 'unknown'

  nrows: -> throw "not implemented"
  ncols: -> throw "not implemented"
  # XXX: define return value.  currently Array<String>
  colNames: -> throw "not implemented"
  contains: (colName) -> colName in @colNames()

  @merge: (tables) -> gg.RowTable.merge tables

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
    schema = new gg.Schema
    row = if rows.length > 0 then rows[0] else {}
    row = row.raw() if _.isSubclass row, gg.Row
    _.each row, (v,k) ->
      type = gg.Schema.type v
      schema.addColumn k, type.type, type.schema
    schema







class gg.RowTable extends gg.Table
  constructor: (@schema, rows=[]) ->
    throw Error("schema not present") unless @schema?
    @rows = []
    _.each rows, (row) => @addRow row


  @fromArray: (rows) ->
    schema = gg.Table.inferSchemaFromObjs rows
    table = new gg.RowTable schema, rows
    table


  @toRow: (data, schema) ->
    if _.isSubclass data, gg.Row
      if data.schema != schema
        row = data.clone()
        row.schema = schema
        row
      else
        data
    else
      new gg.Row data, schema

  reloadSchema: ->
    rows = _.map(@rows, (row) -> row.raw())
    @schema = gg.Table.inferSchemaFromObjs rows
    @

  nrows: -> @rows.length
  ncols: -> @schema.nkeys()
  colNames: -> @schema.attrs()

  cloneShallow: ->
    rows = @rows.map (row) -> row
    new gg.RowTable @schema, rows

  cloneDeep: ->
    rows = @rows.map (row) => row.clone()
    new gg.RowTable @schema, rows


  merge: (table) ->
    # ensure schemas
    if _.isSubclass table, gg.RowTable
      @rows.push.apply @rows, table.rows
    else
      throw Error("merge not implemented for #{@constructor.name}")
    @

  @merge: (tables) ->
    if tables.length == 0
        new gg.RowTable @schema
    else
        t = tables[0].cloneShallow()
        for t2, idx in tables
            t.merge(t2) if idx > 0
        t


  # gbfunc's output will be JSON encoded to differentiate groups
  # however the actual key will be the original gbfunc's output
  # @param {Function} gbfunc (row) -> key
  # @return {Array} of objects: {key: group key, table: partition}
  split: (gbfunc) ->
    if _.isString gbfunc
      gbfunc = ((key) -> (tuple) -> tuple.get(key))(gbfunc)


    keys = {}
    groups = {} # arrays of rows
    _.each @rows, (row) ->
      key = gbfunc row
      jsonKey = JSON.stringify key
      groups[jsonKey] = [] if jsonKey not of groups
      groups[jsonKey].push row
      keys[jsonKey] = key


    ret = []
    _.each groups, (rows, jsonKey) ->
      partition = gg.RowTable.fromArray rows
      ret.push {key: keys[jsonKey], table: partition}
    ret

  flatten: ->
    table = new gg.RowTable @schema.flatten()
    @each (row) -> table.merge row.flatten()
    table

  # @param colname either a string, or an object of {key: xform} pairs
  # @param {Function|boolean} funcOrUpdate
  #        if colname is a string, funcOrUpdate is a transformation
  #        function (val, row) -> newVal.
  #        if colname is an object, used as update (see below)
  # @param {boolean} update
  #        true if transformation should update the table
  #        false if rows should be new, with only columns specified by transformation
  #
  transform: (colname, funcOrUpdate=yes, update=yes) ->
    if _.isObject colname
        mapping = colname
        update = funcOrUpdate
    else
        mapping = {}
        mapping[colname] = funcOrUpdate

    funcs = {}
    strings = {}
    if update
      @each (row) =>
        newrow = @transformRow row, mapping, funcs, strings
        row.merge newrow
      @reloadSchema()
      @
    else
      newrows = _.map @rows, (row) =>
        @transformRow row, mapping, funcs, strings
      new gg.RowTable newrows

  # constructs a new object and populates it using mapping specs
  transformRow: (row, mapping, funcs={}, strings={}) ->
    ret = {}
    map = (oldattr, newattr) =>
      if _.isFunction oldattr
        oldattr row
      else if row.hasAttr oldattr
        row.get oldattr
      else if newattr of strings
        strings[newattr]
      else if newattr isnt 'text' and gg.Table.reEvalJS.test oldattr
        #
        # XXX: WARNING!! This entire functionality is really dangerous and
        #      can easily be abused!!  WARNING!
        #
        unless newattr of funcs
          userCode = oldattr[1...oldattr.length-1]
          variableF = (key) =>
            # if the key is a well-specified variable name
            if gg.Table.reVariable.test(key)
              "var #{key} = row.get('#{key}');"
            else
              null

          cmds = _.compact _.map(row.attrs(), variableF)
          cmds.push "return #{userCode};"
          cmd = cmds.join('')
          fcmd = "var __func__ = function(row) {#{cmd}}"
          console.log fcmd
          eval fcmd
          funcs[newattr] = __func__
        funcs[newattr](row)
      else
        # for constrants (e.g., date, number)
        oldattr


    _.each mapping, (oldattr, newattr) =>
      ret[newattr] = try
        map oldattr, newattr
      catch error
        console.log error
        throw error
    new gg.Row ret


  # create new table containing the (exactly same)
  # rows from current table, with rows failing the filter
  # test not present
  filter: (f) ->
    newrows = []
    @each (row, idx) -> newrows.push row if f(row, idx)
    new gg.RowTable newrows, @schema


  # transforms the values of column(s) on a per-column basis
  # Destructively updates!
  # Each mapping function takes the current field as input
  map: (fOrMap, colName=null) ->
    if _.isFunction fOrMap
      throw Error("RowTable.map without colname!") unless colName?
      f = fOrMap
      fOrMap = {}
      fOrMap[colName] = f

    @each (row, idx) ->
      _.each fOrMap, (f, col) ->
        if row.inArray col
          arr = _.map row.get(col), f
          row.set col, arr
        else
          row.set(col, f(row.get(col)))

    unless _.all(fOrMap, (f,col) => @contains col)
      @reloadSchema()
    @


  addConstColumn: (name, val, type=null) ->
    type = gg.Schema.type(val) unless type?
    @addColumn name, _.repeat(@nrows(), val), type

  addColumn: (name, vals, type=null) ->
    if vals.length != @nrows()
      throw Error("column has #{vals.length} values,
        table has #{@rows.length} rows")
    if @schema.contains name
      throw Error("column #{name} already exists in table")

    unless type?
      type = if vals.length is 0
        {type: gg.Schema.unknown, schema: null}
      else
        gg.Schema.type vals[0]

    @schema.addColumn name, type.type, type.schema
    @rows.forEach (row, idx) => row.addColumn(name, vals[idx])
    @

  addRow: (row) ->
    # enforce schema
    @rows.push gg.RowTable.toRow(row, @schema)
    @


  get: (row, col=null) ->
    if row >= 0 and row < @rows.length
      if col?
          @rows[row].get col
      else
          @rows[row]
    else
      null

  getCol: (col) -> @getColumn col
  getColumn: (col) ->
    # XXX: hack.  make it do the right thing if no rows
    if @nrows() > 0 and @get(0).hasAttr col
      if @get(0).inArray(col)
        _.flatten _.times @nrows(), (idx) => @get(idx, col)
      else
        _.times @nrows(), (idx) => @get(idx, col)
    else
      null

  asArray: -> _.map @rows, (row) -> row
  raw: -> _.map @rows, (row) -> row.raw()
  rows: @rows




