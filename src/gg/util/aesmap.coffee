#<< gg/data/table

class gg.util.Aesmap

  @mappingToFunctions: (table, mapping) ->
    ret = {}
    _.each mapping, (val, key) ->
      ret[key] = _.mapToFunction table, key, val
    ret

  @mapToFunction: (table, key, val) ->
    if _.isFunction val
      val
    else if table.contains val
      (row) -> row.get val
    else if _.isObject val
      funcs = _.mappingToFunctions table, val
      (row) ->
        ret = {}
        _.each funcs, (f, subkey) ->
          ret[subkey] = f row
        return ret
    else if key isnt 'text' and gg.data.Table.reEvalJS.test val
      userCode = val[1...val.length-1]
      varFunc = (k) ->
        if gg.data.Table.reVariable.test k
          "var #{k} = row.get('#{k}');"

      cmds = _.compact _.map(table.schema.attrs(), varFunc)
      cmds.push "return #{userCode};"
      cmd = cmds.join ''
      fcmd = "var __func__ = function(row) {#{cmd}}"
      console.log fcmd
      eval fcmd
      __func__
    else
      # for constants (e.g., date, number)
      console.log "mapToFunction: constant funct for : #{key}:#{val}"
      (row) -> val


