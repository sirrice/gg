#<< gg/util/log
#<< gg/core/xform

class gg.xform.DetectScales extends gg.core.XForm
  @ggpackage = "gg.xform.DetectScales"

  parseSpec: ->
    super

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    aes = params.get 'aes'

    constantCols = []
    _.each aes, (v, k) ->
      if _.isNumber(v) or (
        _.isString(v) and 
        not table.has(v) and 
        not gg.util.Aesmap.isEvalJS(v))
        constantCols.push k
    @log "constant columns: #{constantCols}"

    md.each (row) ->
      config = row.get 'scalesconfig'
      layer = row.get 'layer'
      _.each constantCols, (col) ->
        config.layerSpec(layer)[col] = new gg.scale.Identity
          aes: col
    pairtable



class gg.xform.UseScales extends gg.core.XForm
  @ggpackage = "gg.xform.UseScales"

  parseSpec: ->
    super
    @params.putAll
      aess: @spec.aess or []

  compute: (pairtable, params) ->
    pairtable = gg.core.FormUtil.ensureScales pairtable, params, @log
    table = pairtable.left()
    md = pairtable.right()

    scales = md.any().get 'scales'
    posMapping = md.any().get 'posMapping'

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

      scale = scales.get col, tabletype, posMapping
      scaletype = scale.type

      unless scaletype is data.Schema.unknown
        if tabletype >= scaletype
          log "settype: #{col}\t#{scaletype} from #{tabletype}"
          table.schema.setType col, scaletype
        else
          log.warn "Upcasting #{col}: #{tabletype}->#{scaletype}"
          table.schema.setType col, scaletype
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

  useScales: (table, scales, posMapping) -> table
