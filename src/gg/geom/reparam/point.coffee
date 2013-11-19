#<< gg/core/xform

class gg.geom.reparam.Point extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Point"

  defaults:  -> 
    r: 5
    y: 0

  inputSchema:  -> ['x']

  outputSchema: (pairtable) ->
    schema = pairtable.leftSchema().clone()

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
    table = pairtable.left()
    md = pairtable.right()
    schema = params.get('outputSchema') pairtable
    mapping = [
      { 
        alias: 'y1'
        f: (y1, y, r) -> if y1? then y1 else y+r
        type: data.Schema.numeric
        cols: ['y1', 'y', 'r']
      }
      { 
        alias: 'y0'
        f: (y0, y, r) -> if y0? then y0 else y-r
        type: data.Schema.numeric
        cols: ['y0', 'y', 'r']
      }
      { 
        alias: 'x1'
        f: (x1, x, r) -> if x1? then x1 else x+r
        type: data.Schema.numeric
        cols: ['x1', 'x', 'r']
      }
      { 
        alias: 'x0'
        f: (x0, x, r) -> if x0? then x0 else x-r
        type: data.Schema.numeric
        cols: ['x0', 'x', 'r']
      }
    ]
    table = table.project mapping, yes
    pairtable.left table
    pairtable



