

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

    each: (f, n=null) -> _.each _.range(if n? then n else  @nrows()), (i) => f @get(i), i
    # XXX: destructive!
    # updates column values in place
    # @param {Function or map} fOrName
    #        must specify colName if fOrMap is a Function
    #        otherwise, fOrMap is a mapping from colName --> (old val)->new val
    # @param {String} colName
    #        is specified if fOrName is a function, otherwise ignored
    map: (fOrMap, colName=null) -> throw Error("not implemented")
    clone: -> @cloneShallow()
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




class gg.Row
  constructor: (@data) ->
  get: (attr) ->
    if attr of @data
      val = @data[attr]
      if _.isFunction val then val() else val
    else
      maps = _.values(@data).filter ((v) -> _.isObject(v) and not _.isArray(v))
      for map, idx in maps
        if attr of map
          return map[attr]
      return null

  # retrieve the object field that contains attr as an attribute
  # @param attr attribute to search for
  getNested: (attr) ->
    for k, v of @data
      if _.isObject(v) and (not _.isArray(v)) and attr of v
          return v
    null

  set: (attr, val) ->
    if attr of @data
      @data[attr] = val
    else
      nested = @getNested attr
      if nested?
        nested[attr] = val
      else
        @data[attr] = val

  attrs: ->
    rawattrs = []
    nestedattrs = []
    for k,v of @data
      if _.isObject(v) and not _.isArray(v)
        nestedattrs.push k
      else
        rawattrs.push k
    nestedattrs = _.flatten _.map(nestedattrs, (attr) => _.keys(@data[attr]))
    _.union rawattrs, nestedattrs

  merge: (row) -> _.extend @data, row.data

  hasAttr: (attr) -> attr of @data or @getNested(attr)?

  addColumn: (attr, val) -> @data[attr] = val

  ncols: -> _.size(@data)

  clone: -> new gg.Row _.clone(@data)

  raw: -> @data






class gg.RowTable extends gg.Table
    constructor: (rows=[]) ->
        @rows = []
        _.each rows, (row) => @addRow row

    @toRow: (data) ->
      if _.isSubclass data, gg.Row
        data
      else
        new gg.Row data

    nrows: -> @rows.length
    ncols: -> if @nrows() > 0 then @rows[0].ncols() else 0
    colNames: ->
      if @nrows() is 0
        throw Error("no rows to extract schema from")
      else
        @get(0).attrs()

    cloneShallow: -> new gg.RowTable(@rows.map (row) -> row)
    cloneDeep: -> new gg.RowTable(@rows.map (row) => row.clone())


    merge: (table) ->
      if _.isSubclass table, gg.RowTable
          @rows.push.apply @rows, table.rows
      else
          throw Error("merge not implemented for #{@constructor.name}")
      @

    @merge: (tables) ->
      if tables.length == 0
          new gg.RowTable []
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
      groups = {}
      @rows.forEach (row) ->
        # NOTE: also gbfunc.apply(row) to set this?
        key = gbfunc row
        jsonKey = JSON.stringify key
        groups[jsonKey] = new gg.RowTable() if jsonKey not of groups
        groups[jsonKey].addRow row
        keys[jsonKey] = key

      ret = []
      _.each groups, (partition, jsonKey) ->
        ret.push {key: keys[jsonKey], table: partition}
      ret

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
      @each (row, idx) -> newrows.push row if f(row)
      new gg.RowTable newrows


    # transforms the values of column(s) on a per-column basis
    # Destructively updates!
    # Each mapping function takes the current field as input
    map: (fOrMap, colName=null) ->
      if _.isFunction fOrMap
        f = fOrMap
        if colName?
          @each (row, idx) -> row.set(colName, f(row.get(colName)))
        else
          throw Error("RowTable.map without a colname is not implemented")
      else if _.isObject fOrMap
        @each (row, idx) ->
          _.each fOrMap, (f, col) -> row.set(col, f row.get(col))
      else
        throw Error("RowTable.map: invalid arguments: #{arguments}")

      @


    addConstColumn: (name, val, type=null) ->
      @addColumn name, _.repeat(@nrows(), val), type

    addColumn: (name, vals, type=null) ->
      if vals.length != @nrows()
          throw Error("column has #{vals.length} values, table has #{@rows.length} rows")
      @rows.forEach (row, idx) => row.addColumn(name, vals[idx])
      @

    addRow: (row) ->
      @rows.push gg.RowTable.toRow row
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
      if @nrows() > 0 and @get(1, col)?
        _.times @nrows(), (idx) => @get(idx, col)
      else
        null

    asArray: -> _.map @rows, (row) -> row.raw()
    raw: -> @asArray()


class gg.ColTable extends gg.Table


