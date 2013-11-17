_ = require 'underscore'




class data.util.Util
  @isValid: (v) -> not(_.isNull(v) or _.isNaN(v) or _.isUndefined(v))

  @hashCode: (s) ->
    f = (a,b)->
      a=((a<<5)-a)+b.charCodeAt(0)
      a&a
    s.split("").reduce(f ,0)

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
        ret.props[k] = data.util.Util.toJSON(o[k], reject, path)
        path.pop()
    else if _.isArray o
      ret = { type: "array", val: [], props: {} }
      _.each o, (v, idx) ->
        path.push idx
        ret.val.push data.util.Util.toJSON(v, reject, path)
        path.pop()
      _.each _.reject(_.keys(o), _.isNumber), (k) ->
        path.push k
        ret.props[k] = data.util.Util.toJSON(o[k], reject, path)
        path.pop()
    else if _.isDate o
      ret = { type: "date", val: JSON.stringify o }
    else if _.isObject o
      ret = { type: "object", val: {} }
      _.each o, (v,k) ->
        path.push k
        ret.val[k] = data.util.Util.toJSON(v, reject, path)
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
          ret.push data.util.Util.fromJSON(v)
        _.each json.props, (vjson, k) ->
          ret[k] = data.util.Util.fromJSON(vjson)
        ret
      when 'date'
        ret = new Date JSON.parse(json.val)
      when 'object'
        ret = {}
        _.each json.val, (v, k) ->
          ret[k] = data.util.Util.fromJSON(v)
        ret
      when 'function'
        try
          ret = Function("return (#{json.val})")()
        catch err
          throw Error(json.val)
        _.each json.props, (vjson, k) ->
          ret[k] = data.util.Util.fromJSON(vjson)
        ret
      when 'rejected'
        null
      when 'primitive'
        JSON.parse json.val
      else
        throw Error "unexpected json object: #{json}"


  # reach into object o using path
  #
  # @return value at path, or null
  @reach: (o, path) ->
    for col in path
      break unless o?
      o = o[col]
    o


  @ggklass: (ggpackage) ->
    cmd = "return ('gg' in window)? window.#{ggpackage} : #{ggpackage}"
    Function(cmd)()


  # @param f returns an array [key, val]
  #        that sets the map's key, value pair
  @o2map: (o, f=((v, idx)->[v,v])) ->
    ret = {}
    _.each o, (args...) ->
      pair = f args...
      ret[pair[0]] = pair[1] if pair?
    ret




  @isSubclass: (instance, partype) ->
      c = instance
      while c?
          if c.constructor.name is partype.name
              return yes
          unless c.constructor.__super__?
              return no
          c = c.constructor.__super__

  @isType: (args...) -> @isSubclass args...








_.mixin
  toJSON: data.util.Util.toJSON
  fromJSON: data.util.Util.fromJSON
  ggklass: data.util.Util.ggklass
  o2map: data.util.Util.o2map
  isSubclass: data.util.Util.isSubclass
  isType: data.util.Util.isSubclass
  reach: data.util.Util.reach
  hashCode: data.util.Util.hashCode
  isValid: data.util.Util.isValid

