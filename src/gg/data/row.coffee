#<< gg/util/log
#<< gg/data/schema

class gg.data.Row
  @log = gg.util.Log.logger "Row"
  @isNested = (o) -> _.isObject(o) and not _.isArray(o)

  constructor: (@data, @schema) ->
    @log = gg.data.Row.log


  rawKeys: ->
    _.compact _.map @data, (v,k) ->
      k unless _.isObject v

  nestedKeys: ->
    _.compact _.map @data, (v,k) =>
      k if @schema.isNested v

  # attribute within nested tuple to @data key
  nestedToKey: ->
    ret = {}
    _.each @nestedKeys(), (k) =>
      _.each _.keys(@data[k]), (attr) =>
        ret[attr] = k
    ret

  nestedAttrs: ->
    _.compact _.flatten _.map @nestedKeys(), (k) => _.keys(@data[k])


  arrKeys: ->
    @schema.attrs().filter (attr) =>
      @schema.inArray(attr) or @schema.isArray(attr)

    #_.compact _.map @data, (v,k) -> k if _.isArray v

  # attribute of tuple within array to @data key
  arrToKey: ->
    _.list2map @arrAttrs(), (attr) =>
      [attr, @schema.attrToKeys[attr]]
    #ret = {}
    #_.each @arrKeys(), (k) =>
    #  if @data[k]?
    #    for o in @data[k]
    #      if o?
    #        _.each _.keys(o), (attr) => ret[attr] = k
    #        return
    #ret

  arrAttrs: ->
    @schema.attrs().filter (attr) =>
      @schema.inArray attr
    #_.compact _.flatten _.map @arrKeys(), (k) =>
    #  if @data[k]?
    #    for o in @data[k]
    #      try
    #        return _.keys(o) if o?
    #      catch error
    #        @log.warn error
    #        @log.warn k
    #        @log.warn o
    #        @log.warn @
    #        throw error

    #  []

  attrs: ->
    attrs = [
      _.keys(@data),
      @nestedAttrs(),
      @arrAttrs()
    ]
    _.uniq _.flatten attrs

  # this is so the language for "contains attribute"
  # is consistent between Schema, Table, and Row
  contains: (attr) -> @hasAttr(attr)
  hasAttr: (attr) ->
    attr of @data or
      (attr in @nestedAttrs()) or
      (attr in @arrAttrs())

  inArray: (attr) -> attr in @arrAttrs()
  inNested: (attr) -> attr in @nestedAttrs()

  get: (attr) ->
    valOrArr = @_get attr
    if valOrArr?
      if _.isArray valOrArr
        # XXX: use schema to check for function type
        if valOrArr.length > 0 and _.isFunction valOrArr[0]
          _.map valOrArr, (f) -> f()
        else
          valOrArr
      # XXX: use schema to check for function type
      else if _.isFunction valOrArr
        valOrArr()
      else
        valOrArr
    else
      null

  _get: (attr) ->
    if attr of @data
      @data[attr]
    else if @schema.inNested attr
      #else if attr in @nestedAttrs()
      key = @schema.attrToKeys[attr]
      if key of @data and attr of @data[key]
        @data[key][attr]
      else
        null
    else if @schema.inArray attr# in @arrAttrs()
      key = @schema.attrToKeys[attr]
      #key = @arrToKey()[attr]
      arr = @data[key] or []
      if arr.length > 0
        arr = _.map arr, (o) ->
          if attr of o then o[attr] else null
      arr
    else
      null

  set: (attr, val) ->
    if @schema.isRaw attr
      @data[attr] = val
    else if @schema.inNested attr# in @nestedAttrs()
      key = @schema.attrToKeys[attr]
      @data[key][attr] = val
    else if @schema.inArray attr# in @arrAttrs()
      unless _.isArray val
        val = [val]

      key = @schema.attrToKeys[attr]
      @data[key] = [] unless key of @data
      arr = @data[key]
      #arr = @data[@arrToKey()[attr]]
      if arr?
        n = Math.max val.length, arr.length
        _.each _.range(val.length), (idx) =>
          if idx < arr.length
            arr[idx][attr] = val[idx]
          else
            arr[idx] = {attr: val}
          if idx == arr.length
            @log.warn "creating new #{val.length-arr.length} objs in set(#{attr})"
      else
        str = "gg.Row.set attr exists as array, but set val is not"
        throw Error(str)
    else
      @data[attr] = val

  project: (attrs) ->
    copy = {}
    _.each attrs, (attr) =>
      if attr in @rawKeys()
        copy[attr] = @data[attr]
      else if attr in @nestedAttrs()
        key = @nestedToKey()[attr]
        copy[key] = {} unless key of copy
        copy[key][attr] = @data[key][attr]
      else if attr in @arrAttrs()
        key = @arrToKey()[attr]
        arr = @data[key]
        if arr? and arr.length > 0
          copy[key] = _.map(arr,()->{}) unless key of copy
          _.each arr, (v, idx) ->
            copy[key][idx][attr] = v[attr] if v?
      else if attr of @data
        copy[attr] = @data[attr]
    new gg.data.Row copy


  merge: (row) ->
    _.extend @data, row.data
    @

  flatten: ->
    arrays = _.compact _.map @arrKeys(), (k) => @data[k]
    nonArrayKeys = _.union @rawKeys(), @nestedKeys()
    maxLen = _.mmax _.map(arrays, (arr)->arr.length)

    unless arrays.length > 0
      return new gg.data.RowTable @schema, [@]

    unless maxLen? and maxLen > 0
      throw Error("whoops")
      return new gg.data.RowTable @schema.flatten(), [@]


    rowDatas = _.map _.range(maxLen), (idx) =>
      rowData = _.pick @data, nonArrayKeys
      _.each arrays, (arr) ->
        _.extend rowData, arr[idx] if idx < arr.length
      rowData

    gg.data.RowTable.fromArray rowDatas


  addColumn: (attr, val) ->
    @data[attr] = val

  ncols: -> _.size(@data)

  clone: ->
    copy = {}
    _.each @data, (v, k) ->
      copy[k] = if _.isArray v
        _.map v, (o) -> _.clone o
      else if _.isObject v
        _.clone v
      else
        v

    new gg.data.Row copy

  raw: -> @data


