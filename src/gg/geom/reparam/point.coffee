#<< gg/core/xform

class gg.geom.reparam.Point extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Point"

  defaults: (table, env, node) -> r: 5

  inputSchema: (table, env) -> ['x', 'y']

  compute: (table, env, params) ->
    table.each (row) ->
      r = row.get('r')
      y = row.get('y')
      x = row.get('x')

      row.set('y1', y + r) unless row.hasAttr('y1')
      row.set('y0', y - r) unless row.hasAttr('y0')
      row.set('x0', x - r) unless row.hasAttr('x0')
      row.set('x1', x + r) unless row.hasAttr('x1')
    table



