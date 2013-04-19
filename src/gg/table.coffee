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




class gg.Row
  @isNested = (o) -> _.isObject(o) and not _.isArray(o)

  constructor: (@data, @schema) ->


  rawKeys: ->
    _.compact _.map @data, (v,k) -> k unless _.isObject v

  nestedKeys: ->
    _.compact _.map @data, (v,k) -> k if gg.Row.isNested(v)

  # attribute within nested tuple to @data key
  nestedToKey: ->
    ret = {}
    _.each @nestedKeys(), (k) =>
      _.each _.keys(@data[k]), (attr) => ret[attr] = k
    ret

  nestedAttrs: ->
    _.compact _.flatten _.map @nestedKeys(), (k) => _.keys(@data[k])


  arrKeys: ->
    _.compact _.map @data, (v,k) -> k if _.isArray v

  # attribute of tuple within array to @data key
  arrToKey: ->
    ret = {}
    _.each @arrKeys(), (k) =>
      if @data[k]?
        for o in @data[k]
          if o?
            _.each _.keys(o), (attr) => ret[attr] = k
            return
    ret

  arrAttrs: ->
    _.compact _.flatten _.map @arrKeys(), (k) =>
      if @data[k]?
        for o in @data[k]
          try
            return _.keys(o) if o?
          catch error
            console.log error
            console.log k
            console.log o
            console.log @
            throw error

      []

  attrs: ->
    attrs = [
      _.keys(@data),
      @nestedAttrs(),
      @arrAttrs()
    ]
    _.uniq _.flatten attrs

  hasAttr: (attr) ->
    attr of @data or
      (attr in @nestedAttrs()) or
      (attr in @arrAttrs())

  inArray: (attr) -> attr in @arrAttrs()
  inNested: (attr) -> attr in @nestedAttrs()

  get: (attr) ->
    valOrArr = @_get attr
    if valOrArr?
      if _.isArray valOrArr
        if valOrArr.length > 0 and _.isFunction valOrArr[0]
          _.map valOrArr, (f) -> f()
        else
          valOrArr
      else if _.isFunction valOrArr
        valOrArr()
      else
        valOrArr
    else
      null

  _get: (attr) ->
    if attr of @data
      @data[attr]
    else if attr in @nestedAttrs()
      key = @nestedToKey()[attr]
      @data[key][attr]
    else if attr in @arrAttrs()
      key = @arrToKey()[attr]
      arr = @data[key]
      if arr.length > 0 and attr of arr[0]
        _.map arr, (o) -> o[attr]
    else
      null

  set: (attr, val) ->
    if attr in @rawKeys()
      @data[attr] = val
    else if attr in @nestedAttrs()
      @data[@nestedToKey()[attr]][attr] = val
    else if attr in @arrAttrs()
      if _.isArray val
        arr = @data[@arrToKey()[attr]]
        if arr?
          n = Math.max val.length, arr.length
          _.each _.range(val.length), (idx) =>
            if idx < arr.length
              arr[idx][attr] = val[idx]
            else
              console.log "warning, creating new objects during set(#{attr})"
              arr[idx] = {attr: val}
        else
          @data[attr] = val
      else
        str = "gg.Row.set attr exists as array, but set val is not"
        throw Error(str)
    else
      @data[attr] = val

  project: (attrs) ->
    copy = {}
    _.each attrs, (attr) =>
      if attr in @rawKeys()
        copy[attr] = @data[attr]
      else if attr in @nestedAttrs()
        key = @nestedToKey()[attr]
        copy[key] = {} unless key of copy
        copy[key][attr] = @data[key][attr]
      else if attr in @arrAttrs()
        key = @arrToKey()[attr]
        arr = @data[key]
        if arr? and arr.length > 0
          copy[key] = _.map(arr,()->{}) unless key of copy
          _.each arr, (v, idx) ->
            copy[key][idx][attr] = v[attr] if v?
      else if attr of @data
        copy[attr] = @data[attr]
    new gg.Row copy


  merge: (row) -> _.extend @data, row.data

  flatten: ->
    arrays = _.map @arrKeys(), (k) => @data[k]
    nonArrayKeys = _.union @rawKeys(), @nestedKeys()
    maxLen = _.max _.map(arrays, (arr)->arr.length)

    unless maxLen? and maxLen > 0
      return new gg.RowTable @schema.flatten()

    rowDatas = _.map _.range(maxLen), (idx) =>
      rowData = _.pick @data, nonArrayKeys
      _.each arrays, (arr) ->
        _.extend rowData, arr[idx] if idx < arr.length
      rowData

    gg.RowTable.fromArray rowDatas


  addColumn: (attr, val) ->
    @data[attr] = val

  ncols: -> _.size(@data)

  clone: ->
    copy = {}
    _.each @data, (v, k) ->
      copy[k] = if _.isArray v
        _.map v, (o) -> _.clone o
      else if _.isObject v
        _.clone v
      else
        v

    new gg.Row copy

  raw: -> @data


class gg.Schema
  @ordinal = 0
  @numeric = 2
  @date = 3
  @array = 4
  @nested = 5
  @unknown = -1

  constructor: ->
    @schema = {}
    @attrToKeys = {}

  @fromSpec: (spec) ->
    schema = new gg.Schema
    _.each spec, (v, k) ->
      if _.isObject v
        subSchema = gg.Schema.fromSpec v.schema
        schema.addColumn k, v.type, subSchema
      else
        schema.addColumn k, v

  toJson: ->
    json = {}
    _.each @schema, (v, k) ->
      switch v.type
        when gg.Schema.nested, gg.Schema.array
          json[k] =
            type: v.type
            schema: v.schema.toJson()
        else
          json[k] = v
    json

  addColumn: (key, type, schema=null) ->
    @schema[key] =
      type: type
      schema: schema

    @attrToKeys[key] = key
    switch type
      when gg.Schema.array, gg.Schema.nested
        _.each schema.attrs(), (attr) =>
          @attrToKeys[attr] = key

  flatten: ->
    schema = new gg.Schema
    _.each @schema, (type, key) ->
      switch type.type
        when gg.Schema.array, gg.Schema.nested
          _.each type.schema.schema, (subtype, subkey) ->
            schema.addColumn subkey, subtype.type, subtype.schema
        else
          schema.addColumn key, type.type, type.schema
    schema

  clone: -> gg.Schema.fromSpec @toJson()
  attrs: -> _.keys @attrToKeys
  contains: (attr) -> attr in @attrs()
  nkeys: -> _.size @schema
  toString: -> @toJson()

  type: (attr, schema=null) ->
    schema = @ unless schema?
    key = schema.attrToKeys[attr]
    if schema.schema[key]?
      if key is attr
        schema.schema[key].type
      else
        type = schema.schema[key].type
        subSchema = schema.schema[key].schema
        switch type
          when gg.Schema.array, gg.Schema.nested
            if subSchema?
              subSchema.schema[attr].type
            else
              null
          else
            null
    else
      null

  isKey: (attr) -> attr of @schema
  isOrdinal: (attr) -> @isType attr, gg.Schema.ordinal
  isNumeric: (attr) -> @isType attr, gg.Schema.numeric
  isTable: (attr) -> @isType attr, gg.Schema.array
  isNested: (attr) -> @isType attr, gg.Schema.nested
  isType: (attr, type) -> @type(attr) is type


  @type: (v) ->
    if _.isObject v
      ret = { }
      if _.isArray v
        el = if v.length > 0 and v[0]? then v[0] else {}
        ret.type = gg.Schema.array
      else
        el = v
        ret.type = gg.Schema.nested

      ret.schema = new gg.Schema
      _.each el, (o, attr) ->
        type = gg.Schema.type o
        ret.schema.addColumn attr, type.type, type.schema
      ret
    else if _.isNumber v
      { type: gg.Schema.numeric }
    else if _.isDate v
      { type: gg.Schema.date }
    else
      { type: gg.Schema.ordinal }




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




