#<< gg/core/xform
#<< gg/data/*


# reparameterization needs to separate the original data
# from the derived data, and the bounding box data
class gg.geom.reparam.Boxplot extends gg.core.XForm


  defaults: ->
    x: 1
    group: "1"

  # outliers is an array with schema {outlier:}
  inputSchema: ->
    ['x', 'q1', 'median', 'q3', 'lower', 'upper',
      'outliers', 'min', 'max']

  # outliers is an array with schema {outlier:}
  outputSchema: (table, env) ->
    gg.data.Schema.fromSpec
      group: table.schema.typeObj 'group'
      #x: gg.data.Schema.ordinal
      x: table.schema.type 'x'
      x0: table.schema.type 'x'
      x1: table.schema.type 'x'
      width: gg.data.Schema.numeric
      y0: gg.data.Schema.numeric
      y1: gg.data.Schema.numeric
      q1: gg.data.Schema.numeric
      q3: gg.data.Schema.numeric
      median: gg.data.Schema.numeric
      lower: gg.data.Schema.numeric
      upper: gg.data.Schema.numeric
      outliers:
        type: gg.data.Schema.array
        schema:
          outlier: gg.data.Schema.numeric
      min: gg.data.Schema.numeric
      max: gg.data.Schema.numeric


  compute: (table, env, node) ->
    scales = @scales table, env
    yscale = scales.scale 'y', gg.data.Schema.numeric

    # XXX: currently assumes xs is numerical!!
    #      xs should always be pixel values (numerical)
    xs = _.uniq(table.getColumn("x")).sort d3.ascending
    @log "xs: #{xs}"
    diffs = _.map _.range(xs.length-1), (idx) ->
      xs[idx+1]-xs[idx]
    mindiff = _.mmin diffs or 1
    width = mindiff * 0.8
    width = Math.min width, 40

    mapping = {
        y0: 'min'
        y1: 'max'
        x0: (row) -> row.get('x') - width/2.0
        x1: (row) -> row.get('x') + width/2.0
        #width: width
    }


    mapping = _.mappingToFunctions table, mapping
    table.transform mapping, yes
    table.schema = @outputSchema table, env
    table


