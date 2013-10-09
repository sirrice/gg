#<< gg/util/log
#<< gg/core/xform


# Enforces that the table's schema is consistent with
# the scaleset's data types
class gg.xform.ScalesSchema extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesSchema"

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()

    scaleset = @scales data, params
    posMapping = env.get 'posMapping'
    log = @log

    _.each table.colNames(), (attr) ->
      tabletype = table.schema.type attr
      types = scaleset.types attr, posMapping
      if types.length == 0
        scale = scaleset.scale attr, tabletype, posMapping
        log "settype: #{attr}:#{tabletype} unknown.  create: #{scale.toString()}"
        types = [scale.type]

      else if types.length is 1
        # XXX: type checking and downcast rules here
        stype = types[0]
        unless stype is gg.data.Schema.unknown
          if tabletype >= stype
            log "settype: #{attr}\t#{stype}"
            table.schema.setType attr, stype
          else
            log table.getColumn(attr)[0...10]
            throw Error("Upcast #{attr}: #{tabletype}->#{stype}")

      else if types.length > 1
        throw Error("#{attr} has >1 types in scaleset: #{types}")


    data


# transforms data -> pixel/aesthetic values
class gg.xform.ScalesApply extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesApply"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (data, params) ->
    table = data.table
    env = data.env
    @log "table has #{table.nrows()} rows"
    scales = @scales data, params
    data.table = scales.apply table, env.get('posMapping')
    data


# transforms pixel -> data
class gg.xform.ScalesInvert extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesInvert"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (data, params) ->
    table = data.table
    env = data.env
    scales = @scales data, params
    data.table = scales.invert table, env.get('posMapping')
    data



# Filter out data in table outside the domain of the scale set's scales
class gg.xform.ScalesFilter extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesFilter"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (data, params) ->
    table = data.table
    env = data.env
    @log "table has #{table.nrows()} rows"
    nrows = table.nrows()
    scales = @scales data, params
    @log scales.toString()
    data.table = scales.filter table, env.get('posMapping')
    @log "filtered #{nrows - table.nrows()} rows"
    data


# Ensure that each layer+pane's scale set only has a single scale for a given
# aesthetic
class gg.xform.ScalesValidate extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesValidate"

  compute: (data, params) ->
    table = data.table
    env = data.env
    scaleset = @scales data, params

    _.each scaleset.aesthetics(), (aes) ->
      stypes = scaleset.types(aes)
      if stypes.length > 1
        throw Error("Layer scaleset #{aes} has >1 types: #{stypes}")

    data


