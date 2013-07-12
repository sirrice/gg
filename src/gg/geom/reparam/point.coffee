#<< gg/core/xform

class gg.geom.reparam.Point extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Point"

  defaults:  -> r: 5

  inputSchema:  -> ['x', 'y']

  outputSchema: (data) ->
    table = data.table
    schema = table.schema.clone()
    for col in ['x0', 'x1', 'y0', 'y1']
      unless schema.contains col
        schema.addColumn(col, gg.data.Schema.numeric)
    schema

  compute: (data, params) ->
    table = data.table
    env = data.env
    table.each (row) ->
      r = row.get('r')
      y = row.get('y')
      x = row.get('x')

      row.set('y1', y) unless row.contains('y1')
      row.set('y0', 0) unless row.contains('y0')
      row.set('x0', x - r) unless row.contains('x0')
      row.set('x1', x + r) unless row.contains('x1')
    table.schema = params.get('outputSchema') data
    data



