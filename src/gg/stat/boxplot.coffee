#<< gg/stat/stat


class gg.stat.Boxplot extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Boxplot"
  @aliases = ['boxplot', 'quantile']

  parseSpec: ->
    @params.put 'cols', 'x'
    @params.put 'nBins', -1

    types = _.times 7, () -> data.Schema.numeric
    types.push data.Schema.table
    @params.put 'aggs', [{
      alias: ['q1', 'q3', 'median', 'lower', 'upper', 'min', 'max', 'outlier']
      f: gg.stat.Boxplot.udf
      type: types
      col: 'y'
    }]
    super
    @params.put 'keys', _.uniq(@params.get('keys').concat(['group']))

  inputSchema: -> ['x', 'y']

  outputSchema: (pairtable) ->
    Schema = data.Schema
    schema = pairtable.leftSchema().clone()
    newschema = Schema.fromJSON
      q1: Schema.numeric
      q3: Schema.numeric
      median: Schema.numeric
      lower: Schema.numeric
      upper: Schema.numeric
      min: Schema.numeric
      max: Schema.numeric
      outlier: Schema.table

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

  @udf: (vals) ->
    vals.sort d3.ascending

    # This shiz is not that accurate...
    q1 = d3.quantile vals, 0.25
    median = d3.quantile vals, 0.5
    q3 = d3.quantile vals, 0.75
    min = if vals.length then vals[0] else null
    max = if vals.length then vals[vals.length - 1] else null
    fr = 1.5 * (q3-q1)
    lowerIdx = Math.max(d3.bisectLeft(vals, q1 - fr) - 1, 0)
    upperIdx = (d3.bisectRight vals, q3 + fr, lowerIdx) - 1
    lower = vals[lowerIdx]
    upper = vals[upperIdx]
    outliers = vals.slice(0, lowerIdx).concat(vals.slice(upperIdx + 1))
    outliers = [null] unless outliers.length > 0
    outliers = _.map outliers, (v) -> { outlier : v}
    outlierSchema = new data.Schema ['outlier'], [data.Schema.numeric]
    outliers = new data.RowTable outlierSchema, outliers

    boxstats = 
      q1: q1
      median: median
      q3: q3
      lower: lower
      upper: upper
      min: min
      max: max
      outlier: outliers
    console.log "called udf #{boxstats}"
    boxstats

