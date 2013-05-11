#<< gg/schema

class gg.Row
  @isNested = (o) -> _.isObject(o) and not _.isArray(o)

  constructor: (@data, @schema) ->


  rawKeys: ->
    _.compact _.map @data, (v,k) -> k unless _.isObject v

  nestedKeys: ->
    _.compact _.map @data, (v,k) -> k if gg.Row.isNested(v)

  # attribute within nested tuple to @data key
  nestedToKey: ->
    ret = {}
    _.each @nestedKeys(), (k) =>
      _.each _.keys(@data[k]), (attr) => ret[attr] = k
    ret

  nestedAttrs: ->
    _.compact _.flatten _.map @nestedKeys(), (k) => _.keys(@data[k])


  arrKeys: ->
    _.compact _.map @data, (v,k) -> k if _.isArray v

  # attribute of tuple within array to @data key
  arrToKey: ->
    ret = {}
    _.each @arrKeys(), (k) =>
      if @data[k]?
        for o in @data[k]
          if o?
            _.each _.keys(o), (attr) => ret[attr] = k
            return
    ret

  arrAttrs: ->
    _.compact _.flatten _.map @arrKeys(), (k) =>
      if @data[k]?
        for o in @data[k]
          try
            return _.keys(o) if o?
          catch error
            console.log error
            console.log k
            console.log o
            console.log @
            throw error

      []

  attrs: ->
    attrs = [
      _.keys(@data),
      @nestedAttrs(),
      @arrAttrs()
    ]
    _.uniq _.flatten attrs

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
        if valOrArr.length > 0 and _.isFunction valOrArr[0]
          _.map valOrArr, (f) -> f()
        else
          valOrArr
      else if _.isFunction valOrArr
        valOrArr()
      else
        valOrArr
    else
      null

  _get: (attr) ->
    if attr of @data
      @data[attr]
    else if attr in @nestedAttrs()
      key = @nestedToKey()[attr]
      @data[key][attr]
    else if attr in @arrAttrs()
      key = @arrToKey()[attr]
      arr = @data[key]
      if arr.length > 0 and attr of arr[0]
        _.map arr, (o) -> o[attr]
    else
      null

  set: (attr, val) ->
    if attr in @rawKeys()
      @data[attr] = val
    else if attr in @nestedAttrs()
      @data[@nestedToKey()[attr]][attr] = val
    else if attr in @arrAttrs()
      if _.isArray val
        arr = @data[@arrToKey()[attr]]
        if arr?
          n = Math.max val.length, arr.length
          _.each _.range(val.length), (idx) =>
            if idx < arr.length
              arr[idx][attr] = val[idx]
            else
              console.log "warning, creating new objects during set(#{attr})"
              arr[idx] = {attr: val}
        else
          @data[attr] = val
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
    new gg.Row copy


  merge: (row) -> _.extend @data, row.data

  flatten: ->
    arrays = _.map @arrKeys(), (k) => @data[k]
    nonArrayKeys = _.union @rawKeys(), @nestedKeys()
    maxLen = _.max _.map(arrays, (arr)->arr.length)

    unless maxLen? and maxLen > 0
      return new gg.RowTable @schema.flatten()

    rowDatas = _.map _.range(maxLen), (idx) =>
      rowData = _.pick @data, nonArrayKeys
      _.each arrays, (arr) ->
        _.extend rowData, arr[idx] if idx < arr.length
      rowData

    gg.RowTable.fromArray rowDatas


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

    new gg.Row copy

  raw: -> @data


