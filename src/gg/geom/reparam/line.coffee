#<< gg/core/xform
#<< gg/data/*

class gg.geom.reparam.Line extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Line"

  defaults: ->
    { group: '1' }

  inputSchema: (data) -> ['x', 'y']

  outputSchema: (data) ->
    table = data.table
    env = data.env
    numeric = gg.data.Schema.numeric
    gg.data.Schema.fromSpec
      group: table.schema.typeObj 'group'
      pts:
        type: gg.data.Schema.array
        schema:
          x: numeric
          y: numeric
          y0: numeric
          y1: numeric


  compute: (data, params) ->
    [table, env] = [data.table, data.env]
    scales = @scales data, params
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

    schema = params.get('outputSchema') data, params
    table = new gg.data.RowTable schema, rows
    new gg.wf.Data table, env

