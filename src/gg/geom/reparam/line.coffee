#<< gg/core/xform
#<< gg/data/*

class gg.geom.reparam.Line extends gg.core.XForm

  defaults: (table, env, node) ->
    { group: '1' }

  inputSchema: (table, env) -> ['x', 'y']

  outputSchema: (table, env) ->
    numeric = gg.data.Schema.numeric
    gg.data.Schema.fromSpec
      group: table.schema.typeObj 'group'
      pts:
        type: gg.data.Schema.array
        schema:
          x: numeric
          y: numeric


  compute: (table, env, params) ->
    scales = @scales table, env, params
    y0 = scales.scale('y', gg.data.Schema.numeric).minRange()
    @log "compute: y0 set to #{y0}"
    table.each (row) ->
      row.set('y1', row.get('y')) unless row.hasAttr('y1')
      row.set('y0', y0) unless row.hasAttr('y0')

    groups = table.split 'group'
    rows = _.map groups, (group) =>
      groupTable = group.table
      groupKey = group.key
      rowData =
        pts: groupTable.raw()
        group: groupKey
      @log.warn "group #{JSON.stringify groupKey} has #{groupTable.nrows()} pts"
      rowData

    schema = params.get('outputSchema') table, env, params
    new gg.data.RowTable schema, rows

