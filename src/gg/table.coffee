class gg.Table
    type: (colname) ->
        val = @get(0, colname)
        if val? then typeof val else 'unknown'

    nrows: -> throw "not implemented"
    ncols: -> throw "not implemented"


    cloneShallow: -> throw "not implemented"
    cloneDeep: -> throw "not implemented"
    merge: (table)-> throw "not implemented"
    split: (gbfunc)-> throw "not implemented"
    transform: (colname, func)-> throw "not implemented"
    addColumn: (name, vals, type=null) -> throw "not implemented"
    addRow: (row) -> throw "not implemented"
    get: (row, col=null)-> throw "not implemented"



class gg.RowTable extends gg.Table
    constructor: (@rows=[]) ->
        @rows.forEach gg.RowTable.toTuple

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


    cloneShallow: ->
        new gg.RowTable(@rows.map (row) -> row)

    cloneDeep: ->
        new gg.RowTable(@rows.map (row) -> _.clone(row))


    merge: (table) ->
        if @constructor.name is "gg.RowTable"
            @rows.push.apply @rows, table.rows
        else
            throw Error("merge not implemented")
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
    # @return object with key as JSON.stringify(gbfunc) and value is a table
    split: (gbfunc) ->
        groups = {}
        @rows.forEach (row) ->
            # NOTE: also gbfunc.apply(row) to set this?
            key = JSON.stringify(gbfunc(row))
            groups[key] = new gg.RowTable() if key not of groups
            groups[key].addRow row
        groups

    # @param colname either a string, or an object of {key: xform} pairs
    # @param func transformation function.  ignored if colname is an object
    transform: (colname, func) ->
        pairs = []
        if _.isObject colname
            colname.map (val, key) -> pairs.push [key, val]
        else
            pairs.push [colname, func]
        @rows.forEach (row, idx) ->
            for pair in pairs
                row[pair[0]] = pair[1](row[pair[0]], row)
        @


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


class gg.ColTable extends gg.Table


