#<< gg/data/table

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
      [key, f, gg.data.Schema.unknown]
    else if table.has val
      opstore.writeSchema key, val
      f = (row) -> row.get val
      [key, f, table.schema.type val]
    else if _.isObject val
      if 'f' of val and 'args' of val
        args = val.args
        f = val.f
        [key, f, val.type or gg.data.Schema.unknown]
        unless f.length == args.length
          throw Error()
      else
        funcs = _.mappingToFunctions table, val
        f = (row) ->
          ret = {}
          _.each funcs, (f, subkey) ->
            ret[subkey] = f row
          return ret
        [key, f, gg.data.Schema.object]
    else if key isnt 'text' and gg.data.Table.reEvalJS.test val
      userCode = val[1...val.length-1]
      varFunc = (k) ->
        if gg.data.Table.reVariable.test k
          "var #{k} = row.get('#{k}');"

      cmds = _.compact _.map(table.schema.cols, varFunc)
      cmds.push "return #{userCode};"
      cmd = cmds.join ''
      f = Function("row", cmd)
      [key, f, gg.data.Schema.unknown]
    else
      # for constants (e.g., date, number)
      gg.util.Aesmap.log "mapToFunction: const:  f(#{key})->#{val}"
      f = (row) -> val
      [key, f, gg.data.Schema.type val]


class gg.util.RowWrapper
  constructor: (@row) ->
    @accessed = {}

  get: (attr) ->
    @accessed[attr] = yes
    @row.get attr

  has: (col, type) -> @row.has col, type
