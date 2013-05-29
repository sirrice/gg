#<< gg/core/xform
#<< gg/data/schema

class gg.geom.reparam.Rect extends gg.core.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  inputSchema: ->
    ['x', 'y']

  compute: (table, env, node) ->
    scales = @scales table, env
    yscale = scales.scale 'y', gg.data.Schema.numeric

    # XXX: assume xs is numerical!!
    xs = _.uniq(table.getColumn("x")).sort (a,b)->a-b
    diffs = _.map _.range(xs.length-1), (idx) ->
      xs[idx+1]-xs[idx]
    mindiff = _.mmin diffs or 1
    width = Math.max(1,mindiff * 0.8)
    minY = yscale.minDomain()
    minY = 0
    getHeight = (row) -> yscale.scale(Math.abs(yscale.invert(row.get('y')) - minY))


    mapping =
      x: 'x'
      y: 'y'
      r: 'r'
      x0: (row) -> row.get('x0') or row.get('x') - width/2.0
      x1: (row) -> row.get('x1') or row.get('x') + width/2.0
      y0: (row) -> row.get('y0') or Math.min(yscale.scale(minY), row.get('y'))
      y1: (row) -> row.get('y1') or Math.max(yscale.scale(minY), row.get('y'))
      #width: width

    mapping = _.mappingToFunctions table, mapping
    table.transform mapping, yes
    table


