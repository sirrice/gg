#<< gg/core/xform
#<< gg/data/schema

class gg.geom.reparam.Text extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Text"


  defaults: -> group: {}

  inputSchema: -> ['x', 'y', 'text']

  outputSchema: (pairtable, params) ->
    table = pairtable.getTable()
    schema = table.schema.clone()
    _.each ["x0", "x1", "y0", "y1"], (col) ->
      unless schema.has col
        schema.addColumn col, numeric
    schema

  compute: (pairtable, params) ->
    table = pairtable.getTable()

    cols = ['x', 'y', 'text']

    table = gg.data.Transform.transform table,
      x0: (row) -> row.get 'x'
      x1: (row) -> row.get('x') + _.textSize(row.get 'text').w
      y0: (row) -> row.get 'x'
      y1: (row) -> row.get 'y' + _.textSize(row.get 'text').h

    new gg.data.PairTable table, pairtable.getMD()


