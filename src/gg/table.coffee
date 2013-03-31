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




class gg.RowTable extends gg.Table
    constructor: (rows=[]) ->
        @rows = []
        _.each rows, (row) => @addRow row

    @toTuple: (row) ->
        row.get = (attr, defaultVal=null) ->
            val = row[attr]
            if _.isFunction val
                val(row)
            else
                if val? then val else defaultVal
        row.ncols = -> _.size(row) - 2 # for row.get & row.ncols
        row

    nrows: -> @rows.length
    ncols: -> if @nrows() > 0 then @rows[0].ncols() else 0
    colNames: ->
      if @nrows() is 0
        throw Error("no rows to extract schema from")
      else
        _.keys @get(0)

    cloneShallow: -> new gg.RowTable(@rows.map (row) -> row)
    cloneDeep: -> new gg.RowTable(@rows.map (row) => gg.RowTable.toTuple(_.clone(row)))


    merge: (table) ->
      if @constructor.name is "RowTable"
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

    # gbfunc's output will be JSON encoded and used as key
    # @param {Function} gbfunc (row) -> key
    # @return {Array} of objects: {key: group key, table: partition}
    split: (gbfunc) ->
      if _.isString gbfunc
        gbfunc = ((key) -> (tuple) -> tuple.get(key))(gbfunc)


      groups = {}
      @rows.forEach (row) ->
        # NOTE: also gbfunc.apply(row) to set this?
        key = JSON.stringify(gbfunc(row))
        groups[key] = new gg.RowTable() if key not of groups
        groups[key].addRow row

      ret = []
      _.each groups, (partition, key) ->
        ret.push {key: JSON.parse(key), table: partition}
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
          _.each @rows, (row) =>
              newrow = @transformRow row, mapping, funcs, strings
              _.extend row, newrow
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
        else if oldattr of row
          row[oldattr]
        else if newattr of strings
          strings[newattr]
        else if newattr isnt 'text' and gg.Table.reEvalJS.test oldattr
          #
          # XXX: WARNING!! This entire functionality is really dangerous and
          #      can easily be abused!!  WARNING!
          #
          unless newattr of funcs
            userCode = oldattr[1...oldattr.length-1]
            variableF = (val, k) =>
              if gg.Table.reVariable.test(k)
                "var #{k} = row['#{k}'];"
              else
                null

            cmds = _.compact _.map(row, variableF)
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
      ret


    filter: (f) ->
      newrows = []
      @each (row, idx) -> newrows.push row if f(row)
      new gg.RowTable newrows


    map: (fOrMap, colName=null) ->
      if _.isFunction fOrMap
        f = fOrMap
        if colName?
          @each (row, idx) -> row[colName] = f(row[colName])
        else
          throw Error("RowTable.map without a colname is not implemented")
      else if _.isObject fOrMap
        @each (row, idx) ->
          _.each fOrMap, (f, col) -> row[col] = f row[col]
      else
        throw Error("RowTable.map: invalid arguments: #{arguments}")

      @



    addConstColumn: (name, val, type=null) ->
      @addColumn name, _.repeat(@nrows(), val), type

    addColumn: (name, vals, type=null) ->
      if vals.length != @nrows()
          throw Error("column has #{vals.length} values, table has #{@rows.length} rows")
      @rows.forEach (row, idx) => row[name] = vals[idx]
      @

    addRow: (row) ->
      @rows.push gg.RowTable.toTuple row
      @


    get: (row, col=null) ->
        if row >= 0 and row < @rows.length
            if col?
                @rows[row][col]
            else
                @rows[row]
        else
            null

    getCol: (col) ->
      # XXX: hack.  make it do the right thing if no rows
      if @nrows() > 0 and @get(1, col)?
        _.times @nrows(), (idx) => @get(idx, col)
      else
        null
    getColumn: (col) -> @getCol col

    asArray: -> @rows


class gg.ColTable extends gg.Table


