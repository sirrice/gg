#<< gg/core/xform
#<< gg/data/schema

class gg.geom.reparam.Rect extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Rect"

  parseSpec: ->
    @params.put "padding", _.findGoodAttr @spec, ["pad", "padding"], 0.1
    super

  inputSchema: -> ['x', 'y']

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    scales = md.get 0, 'scales'
    yscale = scales.scale 'y', gg.data.Schema.numeric
    padding = 1.0 - params.get 'padding'

    groups = table.partition 'group'
    width = null
    mindiff = null
    _.each groups, (subtable) ->
      # XXX: assume xs is numerical!!
      xs = _.uniq(subtable.getColumn("x")).sort (a,b)->a-b
      diffs = _.map _.range(xs.length-1), (idx) ->
        xs[idx+1]-xs[idx]
      diffs = [1] unless diffs.length > 0
      mindiff = _.mmin(diffs) or 1
      mindiff *= padding
      subwidth = Math.max(1,mindiff)
      width = subwidth unless width?
      width = Math.min(width, subwidth)

    minY = yscale.minDomain()
    minY = 0
    getHeight = (row) -> yscale.scale(Math.abs(yscale.invert(row.get('y')) - minY))
    @log "mindiff: #{mindiff}\twidth: #{width}"


    mapping =
      x: (row) -> row.get 'x'
      y: (row) -> row.get 'y'
      r: (row) -> row.get 'r'
      x0: (row) -> row.get('x0') or (row.get('x') - width/2.0)
      x1: (row) -> row.get('x1') or (row.get('x') + width/2.0)
      y0: (row) -> row.get('y0') or Math.min(yscale.scale(minY), row.get('y'))
      y1: (row) -> row.get('y1') or Math.max(yscale.scale(minY), row.get('y'))
    mapping = _.map mapping, (f, k) -> [k,f,gg.data.Schema.numeric]
    table = gg.data.Transform.transform table, mapping
    new gg.data.PairTable table, md


