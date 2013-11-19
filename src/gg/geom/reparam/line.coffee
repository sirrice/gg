#<< gg/core/xform

class gg.geom.reparam.Line extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Line"

  inputSchema: -> ['x', 'y']

  outputSchema: (pairtable) ->
    schema = pairtable.leftSchema()
    numeric = data.Schema.numeric
    xtype = schema.type 'x'
    ytype = schema.type 'y'
    data.Schema.fromJSON
      group: schema.type 'group'
      x: xtype
      y: ytype
      y0: ytype
      y1: ytype

  schemaMapping: ->
    y0: 'y'
    y1: 'y'


  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    y0 = scales.scale('y', data.Schema.numeric).minRange()
    @log "compute: y0 set to #{y0}"

    y0f = (y0, y) -> if y0? then y0 else y
    y1f = (y1, y) -> if y1? then y1 else y
    
    mapping = [
      {
        alias: 'y0'
        f: y0f
        type: data.Schema.numeric
        cols: ['y0', 'y']
      }
      {
        alias: 'y1'
        f: y1f
        type: data.Schema.numeric
        cols: ['y1', 'y']
      }
    ]

    table = table.project mapping
    pairtable.left table
    pairtable

