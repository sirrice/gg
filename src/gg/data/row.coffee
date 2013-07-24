#<< gg/util/log
#<< gg/data/schema

class gg.data.Row
  @ggpackage = "gg.data.Row"
  @log = gg.util.Log.logger @ggpackage, "row"
  @isNested = (o) -> _.isObject(o) and not _.isArray(o)

  constructor: (@data, @schema) ->
    @log = gg.data.Row.log
    unless @schema?
      throw Error

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
  # If attr1 is nested type and attr1 + attr1.attr2 are listed,
  # will copy over attr1
  #
  # Really only used for debugging purposes in gg.wf.debug
  project: (attrs) ->
    schema = new gg.data.Schema

    copy = {}
    _.each attrs, (attr) =>
      typeObj = @schema.typeObj attr
      unless typeObj?
        console.log attrs
        console.log attr
        console.log @
        throw Error("couldn't find type for #{attr}")
      schema.addColumn attr, typeObj.type, typeObj.schema
      if @schema.isRaw attr
        copy[attr] = @data[attr]
      else if @schema.inNested attr
        key = @schema.attrToKeys[attr]
        copy[key] = {} unless key of copy
        if key of @data
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
    new gg.data.Row copy, schema

  rmColumns: (attrs) ->
    _.each attrs, (attr) =>
      key = @schema.attrToKeys[attr]
      if @schema.isRaw attr
        delete @data[attr]
      else if @schema.inNested attr
        delete @data[key][attr]
      else if @schema.inArray attr
        arr = @data[key]
        if arr?
          _.each arr, (subrow) -> delete subrow[attr]
    @

  rmColumn: (attr) ->
    @rmColumns _.flatten([attr])

  # XXX: doesn't merge schemas.  Does a blind merge
  merge: (row) ->
    if _.isType row, gg.data.Row
      _.extend @data, row.data
    else
      _.extend @data, row
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
    schema = @schema.flatten cols, recursive
    new gg.data.RowTable schema, rowDatas


  addColumn: (attr, val) -> @data[attr] = val
  rmColumn: (attr, val) ->

  ncols: -> _.size(@data)

  clone: ->
    copy = {}
    _.each @data, (v, k) ->
      copy[k] = if _.isNull v
        null
      else if _.isNaN v
        NaN
      else if _.isArray v
        _.map v, (o) -> _.clone o
      else if _.isDate v
        new Date v
      else if v? and v.clone? and _.isFunction v.clone
        v.clone()
      else if _.isObject v
        _.clone v
      else
        v

    new gg.data.Row copy, @schema

  raw: -> @data

  toString: ->
    unless @schema?
      @log.err "row has no schema"
      @log.err @
      throw Error("row has no schema")
    o = _.o2map @schema.leafAttrs(), (attr) =>
      val = @get attr
      if _.isArray val
        val = _.map val[0..4], JSON.stringify
        val = val.join "\t"
      val = val.toString() if val?
      [attr, val]
    JSON.stringify o
    


