#<< gg/stat/stat


# Performs a left-to-right scan
class gg.stat.CDF extends gg.stat.Stat
  @ggpackage = "gg.stat.CDF"
  @aliases = ['cdf', 'cumulative']


  inputSchema: (data, params) -> ['x', 'y']

  outputSchema: (data, params) ->
    table = data.table
    gg.data.Schema.fromSpec
      x: table.schema.type 'x'
      y: gg.data.Schema.numeric
      perc: gg.data.Schema.numeric
      total: gg.data.Schema.numeric

  schemaMapping: (data, params) ->
    x: 'x'
    bin: 'x'
    y: 'y'
    count: 'y'
    total: 'y'

  compute: (data, params) ->
    table = data.table
    env = data.env

    # assumes one y value per x value and that the
    # x dimension is sorted correctly
    cum = 0
    table.each (row, idx) =>
      x = row.get 'x'
      y = row.get('y') or 0
      if y < 0
        throw Error("y values for CDF should not be negative")

      cum += y
      yp = cum
      row.set 'y', yp
      row.set 'total', yp
      row.set 'perc', 0.0

    @log "cumulative value: #{cum}"

    if cum != 0
      table.each (row, idx) =>
        row.set 'perc', (row.get('y') / cum)

    table.setSchema @outputSchema(data, params)
    data

