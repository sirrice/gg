#<< gg/util/log
#<< gg/data/schema

class gg.data.Row
  @log = gg.util.Log.logger "Row"
  @isNested = (o) -> _.isObject(o) and not _.isArray(o)

  constructor: (@data, @schema) ->
    @log = gg.data.Row.log


  rawKeys: ->
    @schema.attrs().filter (attr) => @schema.isRaw(attr)
  nestedKeys: ->
    @schema.attrs().filter (attr) => @schema.isNested(attr)
  arrKeys: ->
    @schema.attrs().filter (attr) => @schema.isArray(attr)
  attrs: -> @schema.attrs()
  contains: (attr) -> @hasAttr(attr)
  hasAttr: (attr) -> @schema.contains attr
  inArray: (attr) -> @schema.inArray attr
  inNested: (attr) -> @schema.inNested attr

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
      key = @schema.attrToKeys[attr]
      if key of @data and attr of @data[key]
        @data[key][attr]
      else
        null
    else if @schema.inArray attr
      key = @schema.attrToKeys[attr]
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
    else if @schema.inNested attr
      key = @schema.attrToKeys[attr]
      @data[key][attr] = val
    else if @schema.inArray attr
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

  # Project attributes while keeping the nested and array structures
  project: (attrs) ->
    copy = {}
    _.each attrs, (attr) =>
      if @schema.isRaw attr
        copy[attr] = @data[attr]
      else if @schema.inNested attr
        key = @schema.attrToKeys[attr]
        copy[key] = {} unless key of copy
        copy[key][attr] = @data[key][attr]
      else if @schema.inArray attr
        key = @schema.attrToKeys[attr]
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

  # uses Zip semantics for flattening multiple arrays
  flatten: (cols=null, recursive=false) ->
    cols ?= @arrKeys().concat @nestedKeys()
    cols = [cols] unless _.isArray cols

    arrCols = cols.filter (attr) => @schema.isArray attr
    nestedCols = cols.filter (attr) => @schema.isNested attr
    projection = @schema.attrs().filter (attr) =>
      key = @schema.attrToKeys[attr]
      return false if @schema.inArray(attr)
      if @schema.isArray attr
        if attr in arrCols
          false
        else
          true
      else
        if attr in nestedCols
          false
        else
          if @schema.inNested attr
            key in nestedCols
          else
            true

    rawData = {}
    _.each projection, (attr) =>
      rawData[attr] = @schema.extract @data, attr

    # now add in the flattened arrays
    arrays = _.map arrCols, (attr) => @schema.extract @data, attr
    perrow = _.zip.apply _.zip, arrays

    # need to return at least one row even if no arrays
    if perrow.length == 0
      _.each arrCols, (attr) -> rawData[attr] = []
      return new gg.data.RowTable @schema, [rawData]

    rowDatas = _.map perrow, (arrRow) ->
      rowData = _.clone rawData
      _.each arrCols, (attr, idx) ->
        if recursive
          if arrRow[idx]?
            _.extend rowData, arrRow[idx]
        else
          val = arrRow[idx]
          val ?= null
          rowData[attr] = val
      rowData

    # may be inefficient to infer the schema for
    # every flattened row!
    gg.data.RowTable.fromArray rowDatas


  addColumn: (attr, val) -> @data[attr] = val

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


