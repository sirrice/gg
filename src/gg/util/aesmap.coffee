#<< gg/util/util

class gg.util.Aesmap
  @log = gg.util.Log.logger "gg.util.Aesmap", "Aesmap"

  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/

  @isEvalJS: (s) -> gg.util.Aesmap.reEvalJS.test s
  @isVariable: (s) -> @reVariable.test s
  @isNestedAttr: (s) -> @reNestedAttr.test s


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
        allcols = _.uniq _.flatten _.map funcs, (desc) -> desc.cols
        if '*' in allcols
          allcols = '*' 
          f = (row) ->
            ret = {}
            for desc in funcs
              ret[desc.alias] = desc.f row
            return ret
        else 
          col2idx = _.o2map allcols, (col, idx) -> [col, idx]
          f = ((funcs, col2idx) -> 
            () ->
              args = arguments
              ret = {}
              for desc in funcs
                fargs = (args[col2idx[col]] for col in desc.cols)
                fargs.push args[args.length-1]
                ret[desc.alias] = desc.f.apply desc.f, fargs
              ret
          )(funcs, col2idx)
        {alias: key, f:f, cols: allcols}

    else if key isnt 'text' and gg.util.Aesmap.isEvalJS val
      userCode = val[1...val.length-1]
      varFunc = (k) ->
        if gg.util.Aesmap.isVariable k
          "var #{k} = row.get('#{k}');"

      cmds = _.compact _.map(table.schema.cols, varFunc)
      cmds.push "return #{userCode};"
      cmd = cmds.join ''
      console.log cmd
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
