#<< gg/util/log
#<< gg/core/xform


# transforms data -> pixel/aesthetic values
class gg.xform.ScalesApply extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @aess = _.findGoodAttr @spec, ['aess'], []
    @posMapping = @spec.posMapping or {}

  compute: (table, env) ->
    @log "table has #{table.nrows()} rows"
    scales = @scales table, env
    table = scales.apply table, null, @posMapping
    table


# transforms pixel -> data
class gg.xform.ScalesInvert extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @aess = _.findGoodAttr @spec, ['aess'], []
    @posMapping = @spec.posMapping or {}

  compute: (table, env) ->
    scales = @scales table, env
    aess = _.compact(_.union scales.aesthetics(), @aess)
    @log ":aesthetics: #{aess}"
    table = scales.invert table, null, @posMapping
    table



#
class gg.xform.ScalesFilter extends gg.core.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @aess = _.findGoodAttr @spec, ['aess'], []
    @posMapping = @spec.posMapping or {}

  compute: (table, env) ->
    @log "table has #{table.nrows()} rows"
    scales = @scales table, env
    table = scales.filter table, null, @posMapping
    table


