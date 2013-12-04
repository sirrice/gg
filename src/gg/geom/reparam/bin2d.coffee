#<< gg/core/bform
#<< gg/geom/reparam/rect

class gg.geom.reparam.Bin2D extends gg.geom.reparam.Rect
  @ggpackage = "gg.geom.reparam.Bin2d"

  inputSchema: -> ['x', 'y']

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    yscale = scales.scale 'y'
    xscale = scales.scale 'x'
    padding = 1.0 - params.get 'padding'
    console.log _.uniq table.all('y')

    if xscale.type in [data.Schema.ordinal, data.Schema.object]
      w = xscale.range()[1] - xscale.range()[0]
    else
      w = @getRectDiff table, xscale, 'x', padding

    if yscale.type in [data.Schema.ordinal, data.Schema.object]
      h = yscale.range()[1] - yscale.range()[0]
    else
      h = @getRectDiff table, yscale, 'y', padding


    mapping = [
      {
        alias: 'x0'
        f: (x0, x) -> if x0? then x0 else x-w/2.0
        type: data.Schema.numeric
        cols: ['x0', 'x']
      }
      {
        alias: 'x1'
        f: (x1, x) -> if x1? then x1 else x+w/2.0
        type: data.Schema.numeric
        cols: ['x1', 'x']
      }
      {
        alias: 'y0'
        f: (y0, y) -> if y0? then y0 else y-h/2.0
        type: data.Schema.numeric
        cols: ['y0', 'y']
      }
      {
        alias: 'y1'
        f: (y1, y) -> if y1? then y1 else y+h/2.0
        type: data.Schema.numeric
        cols: ['y1', 'y']
      }
      {
        alias: 'fill'
        f: (z, fill) -> if fill? then fill else z
        cols: ['z', 'fill']
        type: data.Schema.numeric
      }
    ]
    table = table.project mapping, yes
    pairtable.left table
    pairtable


  # @param padding multiplier to remove space for padding
  # XXX: assumes x is numeric
  getRectDiff: (table, scale, col, padding=1) ->
    groups = table.partition ['facet-x', 'facet-y', 'group', 'layer']
    diff = scale.range()[1] - scale.range()[0]
    groups.each (row) ->
      vals = row.get('table').all(col)
      vals = _.uniq(vals).sort d3.ascending
      diffs = _.times vals.length-1, (idx) ->
        vals[idx+1] - vals[idx]
      return unless diffs.length > 0

      mindiff = _.mmin(diffs) or 1
      mindiff *= padding
      curdiff = Math.max 1, mindiff
      diff = curdiff unless diff?
      diff = Math.min diff, curdiff
    diff

