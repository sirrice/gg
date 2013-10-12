#<< gg/stat/stat


class gg.stat.Boxplot extends gg.stat.Stat
  @ggpackage = "gg.stat.Boxplot"
  @aliases = ['boxplot', 'quantile']

  defaults: ->
    x: 0

  inputSchema: -> ['x', 'y']#'group']

  outputSchema: (pairtable) ->
    Schema = gg.data.Schema
    schema = pairtable.tableSchema()
    gg.data.Schema.fromJSON
      x: schema.type 'x'
      q1: Schema.numeric
      q3: Schema.numeric
      median: Schema.numeric
      lower: Schema.numeric
      upper: Schema.numeric
      outlier: Schema.numeric
      min: Schema.numeric
      max: Schema.numeric

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

  computeStatistics: (vals) ->
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

    rows = _.map outliers, (v) -> 
      q1: q1
      median: median
      q3: q3
      lower: lower
      upper: upper
      outlier: v
      min: min
      max: max
    rows

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    groups = table.partition 'x'
    rows = []
    _.map groups, (group) =>
      x = group.get 0, 'x'
      ys = group.getColumn 'y'
      for row in @computeStatistics ys
        row.x = x
        rows.push row

    schema = params.get('outputSchema') pairtable, params
    table = gg.data.Table.fromArray rows, schema
    new gg.data.PairTable table, pairtable.getMD()



