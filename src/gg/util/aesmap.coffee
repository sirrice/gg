class gg.util.Aesmap
  @log = gg.util.Log.logger "gg.util.Aesmap", "Aesmap"

  @mappingToFunctions: (table, mapping) ->
    ret = []
    for key, val of mapping
      for newkey in gg.core.Aes.resolve(key)
        ret.push(_.mapToFunction table, newkey, val)
    ret

  @mapToFunction: (table, key, val) ->
    opstore = {}
    opstore.writeSchema = () ->

    if _.isFunction val
      f = (row) -> 
        row = new gg.util.RowWrapper row
        ret = val row
        opstore.writeSchema [key], row.accessed
        ret
      {alias: key, f: f, type: data.Schema.unknown, cols: '*'}

    else if table.has val
      opstore.writeSchema key, val
      f = (v) -> v
      {alias: key, f: f, type: table.schema.type(val), cols: val}

    else if _.isObject val
      if 'f' of val and 'args' of val
        args = val.args
        f = val.f
        unless f.length > args.length
          throw Error "f requires more arguments than specified: #{f.length}>#{args.length}"
        unless _.all(args, (col) -> table.has col)
          throw Error "table doesn't contain all args"
        {alias: key, f: f, cols: args}
      else
        funcs = _.mappingToFunctions table, val
        f = (row) ->
          ret = {}
          _.each funcs, (f, subkey) ->
            ret[subkey] = f row
          return ret
        {alias: key, f:f, cols: '*'}

    else if key isnt 'text' and data.Table.reEvalJS.test val
      userCode = val[1...val.length-1]
      varFunc = (k) ->
        if data.Table.reVariable.test k
          "var #{k} = row.get('#{k}');"

      cmds = _.compact _.map(table.schema.cols, varFunc)
      cmds.push "return #{userCode};"
      cmd = cmds.join ''
      f = Function("row", cmd)
      {alias: key, f: f, type: data.Schema.object, cols: '*'}

    else
      # for constants (e.g., date, number)
      gg.util.Aesmap.log "mapToFunction: const:  f(#{key})->#{val}"
      f = (row) -> val
      {alias: key, f: f, type: data.Schema.object, cols: '*'}


class gg.util.RowWrapper
  constructor: (@row) ->
    @accessed = {}

  get: (attr) ->
    @accessed[attr] = yes
    @row.get attr

  has: (col, type) -> @row.has col, type


_.mixin
  mapToFunction: gg.util.Aesmap.mapToFunction
  mappingToFunctions: gg.util.Aesmap.mappingToFunctions
