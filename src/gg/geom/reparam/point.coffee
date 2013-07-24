#<< gg/core/xform

class gg.geom.reparam.Point extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Point"

  defaults:  -> r: 5

  inputSchema:  -> ['x', 'y']

  outputSchema: (data) ->
    table = data.table
    schema = table.schema.clone()
    xtype = schema.type 'x'
    ytype = schema.type 'y'
    for col in ['x0', 'x1']
      unless schema.contains col
        schema.addColumn col, xtype 
    for col in ['y0', 'y1']
      unless schema.contains col
        schema.addColumn col, ytype
    schema

  compute: (data, params) ->
    table = data.table
    env = data.env
    schema = params.get('outputSchema') data
    table.each (row) ->
      r = row.get('r')
      y = row.get('y')
      x = row.get('x')

      row.set('y1', y) unless row.contains('y1')
      row.set('y0', 0) unless row.contains('y0')
      row.set('x0', x - r) unless row.contains('x0')
      row.set('x1', x + r) unless row.contains('x1')
    table.setSchema schema
    data



