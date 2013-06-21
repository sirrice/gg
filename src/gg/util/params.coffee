#
# Data structure to implement a pseuda-monad
#
class gg.util.Params
  @ggpackage = 'gg.util.Params'
  constructor: (data) ->
    @id = gg.util.Params.id()
    @data = {}
    @merge data

  @id: -> gg.util.Params::_id += 1
  _id: 0


  merge: (data={}) ->
    if _.isSubclass data, gg.util.Params
      data = data.data

    _.each data, (v,k) => @data[k] = v
    @

  put: (key, val) ->
    @data[key] = val
    @

  putAll: (o) ->
    _.each o, (v, k) =>
      @data[k] = v
    @

  # ensure @key exists by trying to retrieve from @altkeys
  # if none of the altKeys exist in @data, set to defaultVal
  ensure: (key, altkeys, defaultVal=null) ->
    return @ if key of @data
    if altkeys?
      for alt in altkeys
        if alt of @data
          @put key, @get(alt)
          return
    @put key, defaultVal
    @

  # o has the following structure:
  #
  #   key -> [[altkeys...], default]
  #
  # value can be
  #
  #   [ altkey1, ..., altkeyn]
  #   [ [altkeys...] ]
  #   [ [altkeys...], default value]
  #
  ensureAll: (o) ->
    _.each o, (v, k) =>
      if (_.isArray(v[0]) and v.length is 1)
        v = [v[0], null]
      else if _.isString v[0]
        v = [v, null]
      @ensure k, v[0], v[1]
    @

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
    # compute all the non-JSONable elements
    removedEls =
      svg: @rm 'svg'
      pairs: _.clone(@rm 'pairs')
    _.each _.keys(@data), (key) =>
      if _.isFunction @data[key]
        removedEls[key] = @rm key

    json = @toJSON()
    clone = gg.util.Params.fromJSON json

    @merge removedEls
    clone.merge removedEls
    clone

  toString: ->
    _.map(@data, (v,k) -> "#{k} -> #{JSON.stringify v}").join("\n")

  toJSON: -> _.toJSON @data

  # Only accepts json objects formatted
  # from toJSON above
  #
  # XXX: This is pretty dangerous.
  @fromJSON: (json) ->
    data = _.fromJSON json
    new gg.util.Params data

