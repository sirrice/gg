#<< gg/core/bform

class gg.geom.reparam.Rect extends gg.core.BForm
  @ggpackage = "gg.geom.reparam.Rect"

  parseSpec: ->
    @params.put "padding", _.findGoodAttr @spec, ["pad", "padding"], 0.1
    super

  inputSchema: -> ['x', 'y']

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    yscale = scales.scale 'y', data.Schema.numeric
    xscale = scales.scale 'x', data.Schema.unknown
    padding = 1.0 - params.get 'padding'

    groups = table.partition ['facet-id', 'group', 'layer']
    width = xscale.range()[1] - xscale.range()[0]
    mindiff = null
    groups.each (row) ->
      # XXX: assume xs is numerical!!
      xs = row.get('table').all('x')
      xs = _.uniq(xs).sort ((a,b) -> a-b)
      diffs = _.map _.range(xs.length-1), (idx) ->
        xs[idx+1]-xs[idx]
      return unless diffs.length > 0
      mindiff = _.mmin(diffs) or 1
      mindiff *= padding
      subwidth = Math.max(1,mindiff)
      width = subwidth unless width?
      width = Math.min(width, subwidth)

    minY = yscale.minDomain()
    minY = 0
    getHeight = (row) -> yscale.scale(Math.abs(yscale.invert(row.get('y')) - minY))
    @log "mindiff: #{mindiff}\twidth: #{width}"
    minY = yscale.scale minY


    mapping = [
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


