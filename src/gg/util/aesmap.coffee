#<< gg/util/util

class gg.util.Aesmap
  @log = gg.util.Log.logger "gg.util.Aesmap", "Aesmap"

  @mappingToFunctions: (table, mapping) ->
    ret = []
    for key, val of mapping
      for newkey in gg.core.Aes.resolve(key)
        ret.push(_.mapToFunction table, newkey, val)
    ret

  @mapToFunction: (table, key, val) ->
    if _.isFunction val
      f = (row) -> 
        row = new gg.util.RowWrapper row
        ret = val row
        ret
      {alias: key, f: f, type: data.Schema.unknown, cols: '*'}

    else if table.has val
      f = (v) -> v
      {alias: key, f: f, type: table.schema.type(val), cols: val}

    else if _.isObject val
      # in case it is already a projection description
      if 'f' of val and ('cols' of val or 'args' of val)
        if 'args' of val and not('cols' of val)
          val.cols = val.args

        cols = val.cols
        f = val.f
        type = val.type

        unless f.length > args.length
          throw Error "f requires more arguments than specified: #{f.length}>#{args.length}"
        unless _.all(args, (col) -> table.has col)
          throw Error "table doesn't contain all args"

        {alias: key, f: f, type: type, cols: args}

      else
        # otherwise recursively transform each entry in the object
        funcs = _.mappingToFunctions table, val
        funcs = data.ops.Project.normalizeMappings funcs, table.schema
        allcols = _.uniq _.flatten _.map funcs, (desc) -> desc.cols
        allcols = '*' if '*' in allcols
        f = (row) ->
          ret = {}
          _.each funcs, (desc, subkey) ->
            ret[desc.alias] = desc.f row
          return ret
        {alias: key, f:f, cols: allcols}

    else if key isnt 'text' and data.Table.reEvalJS.test val
      userCode = val[1...val.length-1]
      varFunc = (k) ->
        if data.Table.reVariable.test k
          "var #{k} = row.get('#{k}');"

      cmds = _.compact _.map(table.schema.cols, varFunc)
      cmds.push "return #{userCode};"
      cmd = cmds.join ''
      f = Function("row", cmd)
      {alias: key, f: f, type: data.Schema.unknown, cols: '*'}

    else
      # for constants (e.g., date, number)
      gg.util.Aesmap.log "mapToFunction: const:  f(#{key})->#{val}"
      f = (row) -> val
      {alias: key, f: f, type: data.Schema.type(val), cols: []}


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
