#<< gg/stat/stat


# Performs a left-to-right scan
class gg.stat.CDF extends gg.stat.Stat
  @ggpackage = "gg.stat.CDF"
  @aliases = ['cdf', 'cumulative']


  inputSchema: (pt, params) -> ['x', 'y']

  outputSchema: (pairtable, params) ->
    schema = pairtable.leftSchema()
    newschema = data.Schema.fromJSON
      x: schema.type 'x'
      y: data.Schema.numeric
      perc: data.Schema.numeric
      total: data.Schema.numeric
    schema.merge newschema

  schemaMapping: ->
    x: 'x'
    y: 'y'
    perc: 'y'
    total: 'y'

  compute: (pairtable, params) ->
    table = pairtable.left()

    # assumes one y value per x value and that the
    # x dimension is sorted correctly
    cum = 0
    f = (x, y) ->
      if y < 0 and no
        throw Error("y values for CDF should not be negative")
      cum += y
      yp = cum
      {
        y: yp
        total: yp
        perc: 0.0
      }

    table = table.project [{
      alias: ['y', 'total', 'perc']
      f: f
      type: data.Schema.numeric
      cols: ['x', 'y']
    }], yes

    @log "cumulative value: #{cum}"

    if cum != 0
      table = table.project [{
        alias: 'perc'
        f: (y) -> y / cum
        cols: 'y'
        type: data.Schema.nueric
      }]


    pairtable.left table
    pairtable

