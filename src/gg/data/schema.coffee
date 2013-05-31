#<< gg/util/log

class gg.data.Schema
  @log = gg.util.Log.logger "Schema", gg.util.Log.ERROR

  @ordinal = 0
  @numeric = 2
  @date = 3
  @array = 4
  @nested = 5
  @unknown = -1

  constructor: ->
    @schema = {}
    @attrToKeys = {}
    @log = gg.data.Schema.log

  addColumn: (key, type, schema=null) ->
    @schema[key] =
      type: type
      schema: schema

    @attrToKeys[key] = key
    switch type
      when gg.data.Schema.array, gg.data.Schema.nested
        _.each schema.attrs(), (attr) =>
          @attrToKeys[attr] = key

  # promotes all attributes in cols parameter
  # 1) within nests into raw attributes,
  # 2) arrays to nests
  #
  # e.g., if cols = ['b', 'd']
  #
  #  { a:, b: { c: }, d: [ {e:} ] }
  #
  # is flattened to:
  #
  #  { a:, c:, d: {e:} }
  #
  # @param cols list of nested or array attributes to flatten,
  #        or null to flatten all of them
  #
  flatten:(cols=null, recursive=false) ->
    cols ?= @attrs().filter (attr) => @isArray(attr) or @isNested(attr)
    cols = [cols] unless _.isArray cols

    schema = new gg.data.Schema
    _.each @schema, (type, key) ->
      if key in cols
        if not recursive and type.type == gg.data.Schema.array
          # promote to nested object
          arrSchema = type.schema
          schema.addColumn key, gg.data.Schema.nested, arrSchema
        else
          if recursive or type.type == gg.data.Schema.nested
            # promote subkeys to raw keys
            _.each type.schema.schema, (subtype, subkey) ->
              schema.addColumn subkey, subtype.type, subtype.schema
          else
            schema.addColumn key, type.type, type.schema
      else
        schema.addColumn key, type.type, type.schema

    if no
      switch type.type
        when gg.data.Schema.array, gg.data.Schema.nested
          _.each type.schema.schema, (subtype, subkey) ->
            schema.addColumn subkey, subtype.type, subtype.schema
        else
          schema.addColumn key, type.type, type.schema
    schema

  clone: -> gg.data.Schema.fromSpec @toJSON()
  attrs: -> _.keys @attrToKeys
  contains: (attr, type=null) ->
    if attr in @attrs()
      (type is null) or @isType(attr, type)
    else
      false
  nkeys: -> _.size @schema
  toString: -> JSON.stringify @toJSON()
  toSimpleString: ->
    arr = _.map @attrs(), (attr) => "#{attr}(#{@type(attr)})"
    arr.join " "




  type: (attr, schema=null) ->
    typeObj = @typeObj attr, schema
    return null unless typeObj?
    typeObj.type

  typeObj: (attr, schema=null) ->
    schema = @ unless schema? # schema class object
    _schema = schema.schema   # internal schema datastructure
    key = schema.attrToKeys[attr]

    if _schema[key]?
      if key is attr
        if _schema[key].schema
          json = _schema[key].schema.toJSON()
        else
          json = null
        {
          type: _schema[key].type
          schema: json
        }
      else
        type = _schema[key].type
        subSchema = _schema[key].schema
        switch type
          when gg.data.Schema.array, gg.data.Schema.nested
            if subSchema? and attr of subSchema.schema
              _subSchema = subSchema.schema
              # only allow one level of nesting
              {
                type: _subSchema[attr].type
                schema: null
              }
            else
              @log "type: no type for #{attr} (code 1)"
              null
          else
            @log "type: no type for #{attr} (code 2)"
            null
    else
      @log "type: no type for #{attr} (code 3)"
      null


  isKey: (attr) -> attr of @schema
  isOrdinal: (attr) -> @isType attr, gg.data.Schema.ordinal
  isNumeric: (attr) -> @isType attr, gg.data.Schema.numeric
  isTable: (attr) -> @isType attr, gg.data.Schema.array
  isArray: (attr) -> @isType attr, gg.data.Schema.array
  isNested: (attr) -> @isType attr, gg.data.Schema.nested
  isType: (attr, type) -> @type(attr) == type
  isRaw: (attr) -> attr == @attrToKeys[attr]

  inArray: (attr) ->
    key = @attrToKeys[attr]
    return false if key == attr
    @type(key) == gg.data.Schema.array

  inNested: (attr) ->
    key = @attrToKeys[attr]
    return false if key == attr
    @type(key) == gg.data.Schema.nested



  setType: (attr, newType) ->
    schema = @
    key = schema.attrToKeys[attr]
    if schema.schema[key]?
      if key is attr
        schema.schema[key].type = newType
      else
        type = schema.schema[key].type
        subSchema = schema.schema[key].schema
        switch type
          when gg.data.Schema.array, gg.data.Schema.nested
            if subSchema?
              @log schema
              @log subSchema
              @log attr
              subSchema[attr].type = newType


  # @param rawrow a json object with same schema as this object
  #        e.g., row.raw(), where row.schema == this
  # @param attr an attribute somewhere in this schema
  extract: (rawrow, attr) ->
    return null unless @contains attr
    key = @attrToKeys[attr]
    if @schema[key]?
      if key is attr
        rawrow[key]
      else
        type = @schema[key].type
        subSchema = @schema[key].schema
        subObject = rawrow[key]

        switch type
          when gg.data.Schema.array
            if subSchema? and attr of subSchema.schema
              _.map subObject, (o) -> o[attr]
          when gg.data.Schema.nested
            if subSchema? and attr of subSchema.schema
              subObject[attr]
          else
            null
    else
      null



  @type: (v) ->
    if _.isObject v
      ret = { }
      if _.isArray v
        els = v[0...20]
        ret.type = gg.data.Schema.array
      else
        els = [v]
        ret.type = gg.data.Schema.nested

      ret.schema = new gg.data.Schema
      _.each els, (el) ->
        _.each el, (o, attr) ->
          type = gg.data.Schema.type o
          if ret.schema.contains attr
            # if types not consistent, downcast to ordinal
            unless ret.schema.isType attr, type.type
              ret.schema.setType attr, gg.data.Schema.ordinal
          else
            ret.schema.addColumn attr, type.type, type.schema
      ret
    else if _.isNumber v
      { type: gg.data.Schema.numeric }
    else if _.isDate v
      { type: gg.data.Schema.date }
    else
      { type: gg.data.Schema.ordinal }



  @fromSpec: (spec) ->
    schema = new gg.data.Schema
    _.each spec, (v, k) ->
      if _.isObject v
        if v.schema?
          subSchema = gg.data.Schema.fromSpec v.schema
          schema.addColumn k, v.type, subSchema
        else
          schema.addColumn k, v.type, v.schema
      else
        schema.addColumn k, v
    schema

  @fromJSON: (json) -> @fromSpec json

  toJSON: ->
    json = {}
    _.each @schema, (v, k) ->
      switch v.type
        when gg.data.Schema.nested, gg.data.Schema.array
          json[k] =
            type: v.type
            schema: v.schema.toJSON()
        else
          json[k] = v
    json


