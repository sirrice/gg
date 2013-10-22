#<< gg/stat/stat


class gg.stat.Boxplot extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Boxplot"
  @aliases = ['boxplot', 'quantile']

  parseSpec: ->
    @params.put 'gbAttrs', 'x'
    @params.put 'nBins', -1
    super

  defaults: ->
    x: 0

  inputSchema: -> ['x', 'y']

  outputSchema: (pairtable) ->
    Schema = gg.data.Schema
    schema = pairtable.tableSchema().clone()
    newschema = Schema.fromJSON
      q1: Schema.numeric
      q3: Schema.numeric
      median: Schema.numeric
      lower: Schema.numeric
      upper: Schema.numeric
      outlier: Schema.numeric
      min: Schema.numeric
      max: Schema.numeric
    schema.merge newschema

  schemaMapping: ->
    x: 'x'
    q1: 'y'
    q3: 'y'
    median: 'y'
    lower: 'y'
    upper: 'y'
    outlier: 'y'
    min: 'y'
    max: 'y'

  udf: (table, params) ->
    x = table.get 0, 'x'
    vals = table.getColumn 'y'
    vals.sort d3.ascending

    q1 = d3.quantile vals, 0.25
    median = d3.quantile vals, 0.5
    q3 = d3.quantile vals, 0.75
    min = if vals.length then vals[0] else null
    max = if vals.length then vals[vals.length - 1] else null
    fr = 1.5 * (q3-q1)
    lowerIdx = d3.bisectLeft vals, q1 - fr
    upperIdx = (d3.bisectRight vals, q3 + fr, lowerIdx) - 1
    lower = vals[lowerIdx]
    upper = vals[upperIdx]
    outliers = vals.slice(0, lowerIdx).concat(vals.slice(upperIdx + 1))
    outliers = [null] unless outliers.length > 0

    boxstats = 
      q1: q1
      median: median
      q3: q3
      lower: lower
      upper: upper
      min: min
      max: max
      x: x
    @log "boxstats: #{JSON.stringify boxstats}"

    rows = _.map outliers, (v) -> 
      newrow = table.get(0).raw()
      _.extend newrow, boxstats
      newrow
    rows

