#<< gg/util/log
#<< gg/core/xform


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


