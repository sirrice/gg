#<< gg/stat/stat


# Performs a left-to-right scan
class gg.stat.CDF extends gg.stat.Stat
  @ggpackage = "gg.stat.CDF"
  @aliases = ['cdf', 'cumulative']


  inputSchema: (data, params) -> ['x', 'y']

  outputSchema: (pairtable, params) ->
    schema = pairtable.tableSchema()
    gg.data.Schema.fromJSON
      x: schema.type 'x'
      y: gg.data.Schema.numeric
      perc: gg.data.Schema.numeric
      total: gg.data.Schema.numeric

  schemaMapping: ->
    x: 'x'
    y: 'y'
    perc: 'y'
    total: 'y'

  compute: (pairtable, params) ->
    table = pairtable.getTable()

    # assumes one y value per x value and that the
    # x dimension is sorted correctly
    cum = 0
    rows = table.fastEach (row, idx) =>
      raw = row.raw()
      x = raw.get 'x'
      y = raw.get('y') or 0
      if y < 0 and no
        throw Error("y values for CDF should not be negative")

      cum += y
      yp = cum
      raw.y = yp
      raw.total = yp
      raw.perc = 0.0
      raw

    @log "cumulative value: #{cum}"

    if cum != 0
      for row in rows
        row.perc = (row.y / cum)


    table = gg.data.Table.fromArray rows, @outputSchema(pairtable, params)
    new gg.data.PairTable table, pairtable.getMD()

