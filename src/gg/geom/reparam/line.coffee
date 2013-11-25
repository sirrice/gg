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
    scales = pairtable.right().any 'scales'
    y0 = scales.get('y').minRange()
    @log "compute: y0 set to #{y0}"

    y0f = (y0) -> if y0? then y0 else y0
    y1f = (y1, y) -> if y1? then y1 else y
    
    mapping = []
    unless table.has 'y0'
      mapping.push {
        alias: 'y0'
        f: y0f
        type: data.Schema.numeric
        cols: ['y0']
      }
    unless table.has 'y1'
      mapping.push {
        alias: 'y1'
        f: y1f
        type: data.Schema.numeric
        cols: ['y1', 'y']
      }

    if mapping.length > 0
      table = table.project mapping, yes
    pairtable.left table
    pairtable

