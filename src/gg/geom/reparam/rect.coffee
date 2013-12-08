#<< gg/core/bform

class gg.geom.reparam.Rect extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Rect"

  parseSpec: ->
    super
    @params.put 'keys', ['layer']

  inputSchema: -> ['x', 'y']

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    yscale = scales.scale 'y'
    xscale = scales.scale 'x'
    padding = 1.0 - params.get 'padding'

    minY = yscale.scale 0
    mapping = [
      {
        alias: 'y0'
        f: (y0, y) -> if y0? then y0 else Math.min(minY, y)
        type: data.Schema.numeric
        cols: ['y0', 'y']
      },
      {
        alias: 'y1'
        f: (y1, y) -> if y1? then y1 else Math.max(minY, y)
        type: data.Schema.numeric
        cols: ['y1', 'y']
      }
    ]


    if table.has 'width'
      mapping = mapping.concat [
        {
          alias: 'x0'
          f: (x0, x, width) -> if x0? then x0 else x-width/2.0
          type: data.Schema.numeric
          cols: ['x0', 'x', 'width']
        }
        {
          alias: 'x1'
          f: (x1, x, width) -> if x1? then x1 else x+width/2.0
          type: data.Schema.numeric
          cols: ['x1', 'x', 'width']
        }
      ]

    else
      if xscale.type in [data.Schema.ordinal, data.Schema.object]
        width = xscale.range()[1] - xscale.range()[0]
      else
        width = @getRectWidth table, xscale, padding

      mapping = mapping.concat [
        {
          alias: 'width'
          f: -> width
          type: data.Schema.numeric
          cols: []
        }
        {
          alias: 'x0'
          f: (x0, x) -> if x0? then x0 else x-width/2.0
          type: data.Schema.numeric
          cols: ['x0', 'x']
        }
        {
          alias: 'x1'
          f: (x1, x) -> if x1? then x1 else x+width/2.0
          type: data.Schema.numeric
          cols: ['x1', 'x']
        }
        {
          alias: 'y0'
          f: (y0, y) -> if y0? then y0 else Math.min(minY, y)
          type: data.Schema.numeric
          cols: ['y0', 'y']
        }
        {
          alias: 'y1'
          f: (y1, y) -> if y1? then y1 else Math.max(minY, y)
          type: data.Schema.numeric
          cols: ['y1', 'y']
        }
      ]

    table = table.project mapping, yes
    pairtable.left table
    pairtable


  # @param padding multiplier to remove space for padding
  # XXX: assumes x is numeric
  getRectWidth: (table, xscale, padding=0) ->
    groups = table.partition ['facet-x', 'facet-y', 'group', 'layer']
    width = xscale.range()[1] - xscale.range()[0]
    mindiff = null
    groups.each (row) ->
      xs = row.get('table').all('x')
      xs = _.uniq(xs).sort ((a,b) -> a-b)
      diffs = _.times (xs.length-1), (idx) ->
        xs[idx+1]-xs[idx]
      return unless diffs.length > 0
      mindiff = _.mmin(diffs) or 1
      mindiff *= padding
      subwidth = Math.max 1, mindiff
      width = subwidth unless width?
      width = Math.min width, subwidth
    width

