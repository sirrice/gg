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

  toJson: ->
    json = {}
    _.each @schema, (v, k) ->
      switch v.type
        when gg.data.Schema.nested, gg.data.Schema.array
          json[k] =
            type: v.type
            schema: v.schema.toJson()
        else
          json[k] = v
    json

  addColumn: (key, type, schema=null) ->
    @schema[key] =
      type: type
      schema: schema

    @attrToKeys[key] = key
    switch type
      when gg.data.Schema.array, gg.data.Schema.nested
        _.each schema.attrs(), (attr) =>
          @attrToKeys[attr] = key

  flatten: ->
    schema = new gg.data.Schema
    _.each @schema, (type, key) ->
      switch type.type
        when gg.data.Schema.array, gg.data.Schema.nested
          _.each type.schema.schema, (subtype, subkey) ->
            schema.addColumn subkey, subtype.type, subtype.schema
        else
          schema.addColumn key, type.type, type.schema
    schema

  clone: -> gg.data.Schema.fromSpec @toJson()
  attrs: -> _.keys @attrToKeys
  contains: (attr, type=null) ->
    if attr in @attrs()
      (type is null) or @isType(attr, type)
    else
      false
  nkeys: -> _.size @schema
  toString: -> JSON.stringify @toJson()
  toSimpleString: ->
    arr = _.map @attrs(), (attr) => "#{attr}(#{@type(attr)})"
    arr.join " "

  isRaw: (attr) -> attr == @attrToKeys[attr]

  inArray: (attr) ->
    key = @attrToKeys[attr]
    return false if key == attr
    @type(key) == gg.data.Schema.array

  inNested: (attr) ->
    key = @attrToKeys[attr]
    return false if key == attr
    @type(key) == gg.data.Schema.nested





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
          json = _schema[key].schema.toJson()
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
        el = if v.length > 0 and v[0]? then v[0] else {}
        ret.type = gg.data.Schema.array
      else
        el = v
        ret.type = gg.data.Schema.nested

      ret.schema = new gg.data.Schema
      _.each el, (o, attr) ->
        type = gg.data.Schema.type o
        ret.schema.addColumn attr, type.type, type.schema
      ret
    else if _.isNumber v
      { type: gg.data.Schema.numeric }
    else if _.isDate v
      { type: gg.data.Schema.date }
    else
      { type: gg.data.Schema.ordinal }


