class gg.data.Schema
  @ordinal = 0
  @numeric = 2
  @date = 3
  @array = 4
  @nested = 5
  @unknown = -1

  constructor: ->
    @schema = {}
    @attrToKeys = {}

  @fromSpec: (spec) ->
    schema = new gg.data.Schema
    _.each spec, (v, k) ->
      if _.isObject v
        subSchema = gg.data.Schema.fromSpec v.schema
        schema.addColumn k, v.type, subSchema
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
      if type? then @isType(attr, type) else true
    else
      false
  nkeys: -> _.size @schema
  toString: -> JSON.stringify @toJson()

  type: (attr, schema=null) ->
    schema = @ unless schema?
    key = schema.attrToKeys[attr]
    if schema.schema[key]?
      if key is attr
        schema.schema[key].type
      else
        type = schema.schema[key].type
        subSchema = schema.schema[key].schema
        switch type
          when gg.data.Schema.array, gg.data.Schema.nested
            #console.log "type: #{attr}\t#{JSON.stringify subSchema}"
            if subSchema? and attr of subSchema.schema
              subSchema.schema[attr].type
            else
              console.log "gg.data.Schema.type 1 no type for #{attr}"
              null
          else
            console.log "gg.data.Schema.type 2 no type for #{attr}"
            null
    else
      console.log "gg.data.Schema.type 3 no type for #{attr}"
      null

  isKey: (attr) -> attr of @schema
  isOrdinal: (attr) -> @isType attr, gg.data.Schema.ordinal
  isNumeric: (attr) -> @isType attr, gg.data.Schema.numeric
  isTable: (attr) -> @isType attr, gg.data.Schema.array
  isArray: (attr) -> @isType attr, gg.data.Schema.array
  isNested: (attr) -> @isType attr, gg.data.Schema.nested
  isType: (attr, type) -> @type(attr) is type

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
              console.log schema
              console.log subSchema
              console.log attr
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


