#<< gg/pos/position


#
# Wilkinson, L. (1999) Dot plots. The American Statistician, 53(3), 276-281.
#
# TODO: Distinguish:
#
#  what to do with groups: stack them or let then overwrite each other?
#  binsize: size to compute overlap of dots
#  shapesize: r
#  direction: center? each group of points or bottom at 0?
#
#
class gg.pos.DotPlot extends gg.core.XForm
  @ggpackage = 'gg.pos.DotPlot'
  @aliases = ['dot', 'dotplot']

  parseSpec: ->
    super
    r = _.findGood [@spec.r, @spec.radius, @spec.size, null]
    @params.put 'r', r
    @params.put 'keys', ['facet-x', 'facet-y', 'layer']

  inputSchema: ->
    ['x']

  outputSchema: (pairtable, params) ->
    schema = pairtable.leftSchema().clone()
    newSchema = data.Schema.fromJSON
      y: data.Schema.numeric
      r: data.Schema.numeric
    schema.merge newSchema

  compute: (pairtable, params) ->
    t = pairtable.left()
    md = pairtable.right()
    r = params.get 'r'
    if r?
      t = t.setColVal 'r', r 
    yscale = md.any('scales').get 'y', data.Schema.numeric
    miny = yscale.range()[0]
    cmp = (r1, r2) -> r1.get('x') - r2.get('x')
    t = t.orderby 'x'

    xs = []
    ys = []
    prevx = null
    # remember if previous point was stacked or not
    stacked = no

    t.each (row) ->
      curx = row.get 'x'
      unless _.isValid curx
        xs.push curx
        ys.push null
        return
      if prevx is null or curx-prevx >= r*2
        # start a new column
        prevx = curx
        xs.push prevx
        ys.push r+miny
        stacked = no
      else if curx != prevx
        xs.push prevx+(r/2.0)
        #if stacked or yes
        ys.push (ys[ys.length-1]+r*2)
        #else
        #  ys.push r+miny
        #  stacked = yes
      else 
        # current x is the same as previous
        xs.push curx
        ys.push (ys[ys.length-1]+r*2)
        stacked = yes

    mapping = 
      alias: ['x', 'x0', 'x1', 'y', 'y0', 'y1']
      type: data.Schema.numeric
      cols: ['x', 'y']
      f: (x, y, idx) ->
        x = xs[idx]
        y = ys[idx]
        {
          x
          x0: x - r
          x1: x + r
          y
          y0: y - r
          y1: y + r
        }
    t = t.project [mapping], yes

    sets = _.uniq pairtable.right().all 'scales'
    for set in sets
      yscale = set.get 'y', data.Schema.numeric
      yscale.frozen = yes
      set.get('r', data.Schema.numeric).frozen = yes

    pairtable.left t
    pairtable

