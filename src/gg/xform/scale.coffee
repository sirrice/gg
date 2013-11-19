#<< gg/util/log
#<< gg/core/xform

class gg.xform.UseScales extends gg.core.XForm
  @ggpackage = "gg.xform.UseScales"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (pairtable, params) ->
    pairtable = @ensureScales pairtable, params, @log
    table = pairtable.left()
    md = pairtable.right()

    scales = md.any().get 'scales'
    posMapping = md.any().get 'posMapping'

    @log "table has #{table.nrows()} rows"

    table = @useScales table, scales, posMapping
    pairtable.left table
    pairtable


# Enforces that the table's schema is consistent with
# the scaleset's data types
class gg.xform.ScalesSchema extends gg.xform.UseScales
  @ggpackage = "gg.xform.ScalesSchema"

  useScales: (table, scales, posMapping) ->
    log = @log
    schema = table.schema

    _.each table.cols(), (col) ->
      tabletype = schema.type col
      scaletypes = scales.types col, posMapping

      if scaletypes.length == 0
        scale = scales.scale col, tabletype, posMapping
        log "settype: #{col}:#{tabletype} unknown.  create: #{scale.toString()}"

      else if scaletypes.length == 1
        # XXX: type checking and downcast rules here
        scaletype = scaletypes[0]
        unless scaletype is data.Schema.unknown
          if tabletype >= scaletype
            log "settype: #{col}\t#{scaletype} from #{tabletype}"
            table.schema.setType col, scaletype
          else
            log table.all(col)[0...10]
            throw Error("Upcast #{col}: #{tabletype}->#{scaletype}")

      else
        throw Error("#{col} has >1 types in scaleset: #{scaletypes}")
    table

# transforms data -> pixel/aesthetic values
class gg.xform.ScalesApply extends gg.xform.UseScales
  @ggpackage = "gg.xform.ScalesApply"

  useScales: (table, scales, posMapping) ->
    scales.apply table, posMapping

# transforms pixel -> data
class gg.xform.ScalesInvert extends gg.xform.UseScales
  @ggpackage = "gg.xform.ScalesInvert"

  useScales: (table, scales, posMapping) ->
    scales.invert table, posMapping



# Filter out data in table outside the domain of the scale set's scales
class gg.xform.ScalesFilter extends gg.xform.UseScales
  @ggpackage = "gg.xform.ScalesFilter"

  useScales: (table, scales, posMapping) ->
    scales.filter table, posMapping

# Ensure that each layer+pane's scale set only has a single scale for a given
# aesthetic
class gg.xform.ScalesValidate extends gg.xform.UseScales
  @ggpackage = "gg.xform.ScalesValidate"

  useScales: (table, scales, posMapping) ->
    for col in scales.aesthetics()
      stypes = scales.types col, posMapping
      if stypes.length > 1
        throw Error "Layer scaleset #{col} has >1 types: #{stypes}"
    table
