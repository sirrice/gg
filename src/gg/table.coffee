class gg.Table
    type: (colname) ->
        val = @get(0, colname)
        if val? then typeof val else 'unknown'

    nrows: -> throw "not implemented"
    ncols: -> throw "not implemented"

    @merge: (tables) -> gg.RowTable.merge tables

    each: (f) -> _.each _.range(@nrows()), (i) => f @get(i), i

    cloneShallow: -> throw "not implemented"
    cloneDeep: -> throw "not implemented"
    merge: (table)-> throw "not implemented"
    split: (gbfunc)-> throw "not implemented"
    transform: (colname, func)-> throw "not implemented"
    addColumn: (name, vals, type=null) -> throw "not implemented"
    addRow: (row) -> throw "not implemented"
    get: (row, col=null)-> throw "not implemented"




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
    # more direct implementation
    each: (f) -> _.each @rows, f


    cloneShallow: -> new gg.RowTable(@rows.map (row) -> row)
    cloneDeep: -> new gg.RowTable(@rows.map (row) => @toTuple(_.clone(row)))


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
    # @return object with key as JSON.stringify(gbfunc) and value is a table
    split: (gbfunc) ->
        if typeof gbfunc is "string"
            key = gbfunc
            gbfunc = (tuple) => tuple.get(key)


        groups = {}
        @rows.forEach (row) ->
            # NOTE: also gbfunc.apply(row) to set this?
            key = JSON.stringify(gbfunc(row))
            groups[key] = new gg.RowTable() if key not of groups
            groups[key].addRow row
        groups

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

    transformRow: (row, mapping, funcs, strings) ->
        ret = {}
        map = (oldattr, newattr) =>
            if _.isFunction oldattr
                oldattr row[newattr], row
            else if oldattr of row
                row[oldattr]
            else if newattr of strings
                oldattr
            else if newattr isnt 'text'
                if oldattr.length is 0 or (oldattr[0] is '{' and oldattr[1] is '}')
                    strings[newattr] = oldattr
                else if not (newattr of funcs)
                    cmds = (_.map row, (val, k) => "var #{k} = row['#{k}'];")
                    cmds.push "return #{oldattr};"
                    cmd = cmds.join('')
                    fcmd = "var __func__ = function(row) {#{cmd}}"
                    eval fcmd
                    funcs[newattr] = __func__
                funcs[newattr](row)
            else
                oldattr


        _.each mapping, (oldattr, newattr) =>
            ret[newattr] = try
                    map oldattr, newattr
                catch error
                    console.log error
                    null
        ret




    addColumn: (name, vals, type=null) ->
        if vals.length != @rows.length
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

    getCol: (col) -> _.times @nrows(), (idx) => @get(idx, col)


class gg.ColTable extends gg.Table


