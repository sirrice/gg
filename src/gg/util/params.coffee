#
# Data structure to implement a pseuda-monad
#
class gg.util.Params
  constructor: (data) ->
    @data = {}
    @merge data


  merge: (data) ->
    if data?
      if _.isSubclass data, gg.util.Params
        data = data.data
      _.each data, (v,k) => @data[k] = v

  put: (key, val) -> @data[key] = val
  putAll: (o) -> _.extend @data, o

  # ensure @key exists by trying to retrieve from @altkeys
  # if none of the altKeys exist in @data, set to defaultVal
  ensure: (key, altkeys, defaultVal=null) ->
    return if key of @data
    if altkeys?
      for alt in altkeys
        if alt of @data
          @put key, @get(alt)
          return
    @put key, defaultVal
    return

  # o has the following structure:
  #
  #   key -> [[altkeys...], default]
  #
  # value can be
  #
  #   [ altkey1, ..., altkeyn]
  #   [ [altkeys...] ]
  #   [ [altkeys...], default value]
  ensureAll: (o) ->
    _.each o, (v, k) =>
      if (_.isArray(v[0]) and v.length is 1)
        v = [v[0], null]
      else if _.isString v[0]
        v = [v, null]
      @ensure k, v[0], v[1]


  contains: (key) -> key of @data

  # @param args... arguments passed if return value is a function
  get: (key, args...) ->
    return null unless key of @data

    v = @data[key]
    # XXX: actually support function values
    if _.isFunction v
      if args.length > 0
        return v args...
    v

  rm: (key) ->
    val = @data[key] or null
    delete @data[key]
    val

  clone: ->
    env = new gg.util.Params
    _.each @data, (v,k) =>
      if v? and  _.isFunction v.clone
        env.put k, v.clone()
      else if _.isFunction v
        env.put k, v
      else if _.isArray(v) and v.selectAll? # is this d3 selection?
        env.put k, v
      else
        env.put k, _.clone(v)
    env

  toString: ->
    _.map(@data, (v,k) -> "#{k} -> #{v}").join("\n")

  toJSON: ->
    ret = {}
    _.each @data, (v, k) ->
      if _.isFunction v
        ret[k] = {type: "function", val: v.toString()}
      else
        ret[k] = {type: "object", val: v}
    ret

  # Only accepts json objects formatted
  # from toJSON above
  #
  # XXX: This is pretty dangerous.
  @fromJSON: (json) ->
    json = _.o2map json, (v, k) ->
      val = switch v.type
        when 'function'
          f = Function "return (#{v.val})"
          f()
        else
          v.val
      [k, val]
    new gg.util.Params json

