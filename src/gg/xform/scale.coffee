#<< gg/util/log
#<< gg/core/xform


# Enforces that the table's schema is consistent with
# the scaleset's data types
class gg.xform.ScalesSchema extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  compute: (table, env, params) ->
    scaleset = @scales table, env, params
    posMapping = env.get 'posMapping'
    log = @log
    log.level = gg.util.Log.DEBUG

    _.each table.colNames(), (attr) ->
      tabletype = table.schema.type attr
      types = scaleset.types attr, posMapping
      if types.length == 0
        scale = scaleset.scale attr, tabletype, posMapping
        log "settype: #{attr}:#{tabletype} unknown.  create: #{scale.toString()}"
        types = [scale.type]

      if types.length is 1
        # XXX: type checking and downcast rules here
        stype = types[0]
        unless stype is gg.data.Schema.unknown
          if tabletype >= stype
            table.schema.setType attr, stype
            log "settype: #{attr}\t#{stype}"
          else
            throw Error("Upcast #{attr}: #{tabletype}->#{stype}")

      else if types.length > 1
        throw Error("#{attr} has >1 types in scaleset: #{types}")

    console.log scaleset.toString()

    table


# transforms data -> pixel/aesthetic values
class gg.xform.ScalesApply extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (table, env, params) ->
    @log "table has #{table.nrows()} rows"
    scales = @scales table, env, params
    table = scales.apply table, null, env.get('posMapping')
    table


# transforms pixel -> data
class gg.xform.ScalesInvert extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (table, env, params) ->
    scales = @scales table, env, params
    aess = _.compact(_.union scales.aesthetics(), params.get('aess'))
    @log ":aesthetics: #{aess}"
    table = scales.invert table, null, env.get('posMapping')
    table



#
class gg.xform.ScalesFilter extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (table, env, params) ->
    @log "table has #{table.nrows()} rows"
    scales = @scales table, env, params
    table = scales.filter table, null, env.get('posMapping')
    table


class gg.xform.ScalesValidate extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  compute: (table, env, params) ->
    scaleset = @scales table, env, params

    _.each scaleset.aesthetics(), (aes) ->
      stypes = scaleset.types(aes)
      if stypes.length > 1
        throw Error("Layer scaleset #{aes} has >1 types: #{stypes}")

    table


