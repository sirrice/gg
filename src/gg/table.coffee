class gg.Table
    @toTuple: (row) ->
        row.get = (attr, defaultVal=null) ->
            val = row[attr]
            if _.isFunction val
                val(row)
            else
                if val? then val else defaultVal

    type: (colname) ->
        val = @get(0, colname)
        if val? then typeof val else 'unknown'


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


    cloneShallow: ->
        new gg.RowTable(@rows.map (row) -> row)

    cloneDeep: ->
        new gg.RowTable(@rows.map (row) -> _.clone(row))


    merge: (table) ->
        @rows.push.apply @rows, table.rows
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
            throw "column has #{vals.length} values, table has #{@rows.length} rows"
        @rows.forEach (row, idx) => row[name] = vals[idx]
        @

    addRow: (row) ->
        gg.RowTable.toTuple row
        @rows.push row
        @

    get: (row, col=null) ->
        if row >= 0 and row < @rows.length
            if col?
                @rows[row][col]
            else
                @rows[row]
        else
            null

