#<< gg/geom/reparam/rect

class gg.geom.reparam.Bin2D extends gg.geom.reparam.Rect
  @ggpackage = "gg.geom.reparam.Bin2D"

  inputSchema: -> ['x', 'y', 'z']

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    yscale = scales.scale 'y', data.Schema.numeric
    padding = 1.0 - params.get("padding")

    groups = table.partition ['facetid', 'layer', 'group']
    width = null
    mindiff = null
    _.each groups, (group) ->
      subtable = group.left()

      # XXX: assume xs is numerical!!
      xs = _.uniq(subtable.all("x")).sort (a,b)->a-b
      diffs = _.map _.range(xs.length-1), (idx) ->
        xs[idx+1]-xs[idx]
      mindiff = _.mmin diffs or 1
      mindiff *= padding
      subwidth = Math.max(1,mindiff)
      width = subwidth unless width?
      width = Math.min(width, subwidth)

    minY = yscale.minDomain()
    minY = 0
    getHeight = (row) -> 
      yscale.scale(Math.abs(yscale.invert(row.get('y')) - minY))
    @log "mindiff: #{mindiff}\twidth: #{width}"
    minY = yscale.scale minY

    mapping = {
      alias: ['x', 'y', 'r', 'x0', 'x1', 'y0', 'y1']
      f: (row) ->
        x = row.get 'x'
        y = row.get 'y'
        {
          x: x
          y: y
          r: row.get 'r'
          x0: row.get('x0') or (x - width/2.0)
          x1: row.get('x1') or (x + width/2.0)
          y0: row.get('y0') or Math.min(minY, y)
          y1: row.get('y1') or Math.max(minY, y)
        }
      type: data.Schema.numeric
      cols: '*'
    }

    table = table.project mapping, no

