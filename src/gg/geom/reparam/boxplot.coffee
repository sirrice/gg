#<< gg/core/xform


# reparameterization needs to separate the original data
# from the derived data, and the bounding box data
class gg.geom.reparam.Boxplot extends gg.core.XForm
  @ggpackage = 'gg.geom.reparam.Boxplot'


  defaults: ->
    x: 1

  # outliers is an array with schema {outlier:}
  inputSchema: ->
    ['x', 'q1', 'median', 'q3', 'lower', 'upper',
      'outlier', 'min', 'max']

  # outliers is an array with schema {outlier:}
  outputSchema: (pairtable) ->
    schema = pairtable.leftSchema()
    Schema = data.Schema
    Schema.fromJSON
      group: schema.type 'group'
      x: schema.type 'x'
      x0: schema.type 'x'
      x1: schema.type 'x'
      width: Schema.numeric
      y0: Schema.numeric
      y1: Schema.numeric
      q1: Schema.numeric
      q3: Schema.numeric
      median: Schema.numeric
      lower: Schema.numeric
      upper: Schema.numeric
      outlier: Schema.numeric
      min: Schema.numeric
      max: Schema.numeric


  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    yscale = scales.scale 'y', data.Schema.numeric

    # XXX: currently assumes xs is numerical!!
    #      xs should always be pixel values (numerical)
    xs = _.uniq(table.all("x")).sort d3.ascending
    @log "xs: #{xs}"
    diffs = _.map _.range(xs.length-1), (idx) ->
      xs[idx+1]-xs[idx]
    mindiff = _.mmin diffs or 1
    width = mindiff * 0.8
    width = Math.min width, 40

    mapping = _.mappingToFunctions table, 
      y0: 'min'
      y1: 'max'
    mapping.push {
      alias: 'x0'
      f: (x) -> x - width/2.0
      cols: 'x'
      type: table.schema.type 'x'
    }
    mapping.push {
      alias: 'x1'
      f: (x) -> x + width/2.0
      type: table.schema.type 'x'
      cols: 'x'
    }

    table = table.project mapping, yes
    pairtable.left table
    pairtable

