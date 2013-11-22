

class gg.util.Json
  @toJSON: (o, reject=(()->no), path=[]) ->
    if path.length >= 25
      console.log o
      throw Error("Max stack #{path} hit")
    unless _.isFunction reject
      reject = () -> no
    if reject o
      return { type: "rejected" }
    if o? and 'ggpackage' of o.constructor
      ret = { type: 'gg', ggpackage: o.constructor.ggpackage }
      ret.val = o.toJSON()
    else if _.isFunction o
      # functions are expected to be pure and not use context
      ret = { type: "function", val: null, props: {} }
      ret.val = o.toString()
      _.each _.keys(o), (k) ->
        path.push k
        ret.props[k] = gg.util.Json.toJSON(o[k], reject, path)
        path.pop()
    else if _.isArray o
      ret = { type: "array", val: [], props: {} }
      _.each o, (v, idx) ->
        path.push idx
        ret.val.push gg.util.Json.toJSON(v, reject, path)
        path.pop()
      _.each _.reject(_.keys(o), _.isNumber), (k) ->
        path.push k
        ret.props[k] = gg.util.Json.toJSON(o[k], reject, path)
        path.pop()
    else if _.isDate o
      ret = { type: "date", val: JSON.stringify o }
    else if _.isObject o
      ret = { type: "object", val: {} }
      _.each o, (v,k) ->
        path.push k
        ret.val[k] = gg.util.Json.toJSON(v, reject, path)
        path.pop()
    else
      o = null if _.isUndefined(o)
      ret = { type: 'primitive', val: JSON.stringify(o) }
    ret

  @fromJSON: (json) ->
    type = json.type
    switch json.type
      when 'gg'
        klass = _.ggklass json.ggpackage
        klass.fromJSON json.val
      when 'array'
        ret = []
        _.each json.val, (v) ->
          ret.push gg.util.Json.fromJSON(v)
        _.each json.props, (vjson, k) ->
          ret[k] = gg.util.Json.fromJSON(vjson)
        ret
      when 'date'
        ret = new Date JSON.parse(json.val)
      when 'object'
        ret = {}
        _.each json.val, (v, k) ->
          ret[k] = gg.util.Json.fromJSON(v)
        ret
      when 'function'
        try
          ret = Function("return (#{json.val})")()
        catch err
          throw Error(json.val)
        _.each json.props, (vjson, k) ->
          ret[k] = gg.util.Json.fromJSON(vjson)
        ret
      when 'rejected'
        null
      when 'primitive'
        JSON.parse json.val
      else
        throw Error "unexpected json object: #{json}"

