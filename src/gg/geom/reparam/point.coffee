#<< gg/core/xform

class gg.geom.reparam.Point extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Point"

  defaults:  -> 
    r: 5
    y: 0

  inputSchema:  -> ['x']

  outputSchema: (pairtable) ->
    schema = pairtable.tableSchema().clone()

    xtype = schema.type 'x'
    ytype = schema.type 'y'
    for col in ['x0', 'x1']
      unless schema.contains col
        schema.addColumn col, xtype 
    for col in ['y0', 'y1']
      unless schema.contains col
        schema.addColumn col, ytype
    schema

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    schema = params.get('outputSchema') pairtable
    mapping = 
      'y1': (row) -> if row.has('y1') then row.get('y1') else row.get('y')
      'y0': (row) -> if row.has('y0') then row.get('y0') else 0
      'x0': (row) -> if row.has('x0') then row.get('x0') else row.get('x')-row.get('r')
      'x1': (row) -> if row.has('y1') then row.get('x1') else row.get('x')+row.get('r')
    mapping = _.map mapping, (f, k) -> [k, f, gg.data.Schema.numeric]
    table = gg.data.Transform.transform table, mapping
    new gg.data.PairTable table, md



