#<< gg/util/log
#<< gg/core/xform


# Enforces that the table's schema is consistent with
# the scaleset's data types
class gg.xform.ScalesSchema extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesSchema"

  compute: (pairtable, params) ->
    pairtable = @ensureScales pairtable, params
    table = pairtable.getTable()
    schema = table.schema
    md = pairtable.getMD()

    scaleset = md.get 0, 'scales'
    posMapping = md.get 0, 'posMapping'
    log = @log

    _.each table.cols(), (col) ->
      tabletype = schema.type col
      scaletypes = scaleset.types col, posMapping

      if scaletypes.length == 0
        scale = scaleset.scale col, tabletype, posMapping
        log "settype: #{col}:#{tabletype} unknown.  create: #{scale.toString()}"
        types = [scale.type]

      else if types.length == 1
        # XXX: type checking and downcast rules here
        scaletype = types[0]
        unless scaletype is gg.data.Schema.unknown
          if tabletype >= scaletype
            log "settype: #{col}\t#{scaletype}"
            table.schema.setType col, scaletype
          else
            log table.getColumn(col)[0...10]
            throw Error("Upcast #{col}: #{tabletype}->#{scaletype}")

      else
        throw Error("#{col} has >1 types in scaleset: #{scaletypes}")

    pairtable



# transforms data -> pixel/aesthetic values
class gg.xform.ScalesApply extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesApply"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (pairtable, params) ->
    pairtable = @ensureScales pairtable, params
    table = pairtable.getTable()
    md = pairtable.getMD()

    scales = md.get 0, 'scales'
    posMapping = md.get 0, 'posMapping'

    @log "table has #{table.nrows()} rows"
    table = scales.apply table, posMapping
    new gg.data.PairTable table, md



# transforms pixel -> data
class gg.xform.ScalesInvert extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesInvert"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()

    scales = md.get 0, 'scales'
    posMapping = md.get 0, 'posMapping'
    table = scales.invert table, posMapping
    new gg.data.PairTable table, md



# Filter out data in table outside the domain of the scale set's scales
class gg.xform.ScalesFilter extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesFilter"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()

    scales = md.get 0, 'scales'
    posMapping = md.get 0, 'posMapping'
    table = scales.filter table, posMapping
    new gg.data.PairTable table, md


# Ensure that each layer+pane's scale set only has a single scale for a given
# aesthetic
class gg.xform.ScalesValidate extends gg.core.XForm
  @ggpackage = "gg.xform.ScalesValidate"

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()

    scales = md.get 0, 'scales'
    posMapping = md.get 0, 'posMapping'

    for col in scales.aesthetics()
      stypes = scales.types col
      if stypes.length > 1
        throw Error "Layer scaleset #{col} has >1 types: #{stypes}"
    pairtable

