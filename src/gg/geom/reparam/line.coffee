#<< gg/core/xform
#<< gg/data/*

class gg.geom.reparam.Line extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Line"

  inputSchema: -> ['x', 'y']

  outputSchema: (pairtable) ->
    schema = pairtable.tableSchema()
    numeric = gg.data.Schema.numeric
    xtype = schema.type 'x'
    ytype = schema.type 'y'
    gg.data.Schema.fromJSON
      group: schema.type 'group'
      x: xtype
      y: ytype
      y0: ytype
      y1: ytype

  schemaMapping: ->
    y0: 'y'
    y1: 'y'


  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    scales = md.get 0, 'scales'
    y0 = scales.scale('y', gg.data.Schema.numeric).minRange()
    @log "compute: y0 set to #{y0}"

    y1f = (row) ->
      if row.has('y1') then row.get('y1') else row.get('y')
    y0f = (row) ->
      if row.has('y0') then row.get('y0') else y0

    table = gg.data.Transform.transform table, [
      ['y0', y0f, gg.data.Schema.numeric]
      ['y1', y1f, gg.data.Schema.numeric]
    ]

    schema = params.get('outputSchema') pairtable, params
    new gg.data.PairTable table, md

