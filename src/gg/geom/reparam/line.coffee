#<< gg/core/xform
#<< gg/data/*

class gg.geom.reparam.Line extends gg.core.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  parseSpec: -> super

  defaults: (table, env, node) ->
    { group: '1' }

  inputSchema: (table, env) ->
    ['x', 'y']

  compute: (table, env, node) ->
    scales = @scales table, env
    y0 = scales.scale('y', gg.data.Schema.numeric).minRange()
    @log "compute: y0 set to #{y0}"
    table.each (row) ->
      row.set('y1', row.get('y')) unless row.hasAttr('y1')
      row.set('y0', y0) unless row.hasAttr('y0')


    scales = @scales(table, env)

    groups = table.split 'group'
    rows = _.map groups, (group) =>
      groupTable = group.table
      groupKey = group.key
      rowData =
        pts: groupTable.raw()
        group: groupKey
      @log.warn "group #{JSON.stringify groupKey} has #{groupTable.nrows()} pts"
      rowData

    gg.data.RowTable.fromArray rows

