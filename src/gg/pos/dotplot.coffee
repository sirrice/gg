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
class gg.pos.DotPlot extends gg.wf.SyncExec
  @ggpackage = 'gg.pos.DotPlot'
  @aliases = ['dot', 'dotplot']

  parseSpec: ->
    super
    r = _.findGood [@spec.r, @spec.radius, @spec.size, 3]
    @params.put 'r', r
    @params.put 'keys', ['facet-x', 'facet-y', 'layer']

  inputSchema: ->
    ['x']

  outputSchema: (pairtable, params) ->
    schema = pairtable.tableSchema().clone()
    newSchema = gg.data.Schema.fromJSON
      y: gg.data.Schema.numeric
      r: gg.data.Schema.numeric
    schema.merge newSchema

  compute: (pairtable, params) ->
    t = pairtable.getTable()
    r = params.get 'r'
    t.setColumn 'r', r
    cmp = (r1, r2) -> r1.get('x') - r2.get('x')
    t = gg.data.Transform.sort t, cmp

    xs = []
    ys = []
    prevx = null
    shifted = no

    t.fastEach (row) ->
      curx = row.get 'x'
      unless _.isValid curx
        xs.push curx
        ys.push null
        return
      if prevx is null or curx-prevx > r*2
        prevx = curx
        xs.push prevx
        ys.push r
        shifted = no
      else if curx != prevx
        xs.push prevx+(r/2.0)
        if shifted
          ys.push (ys[ys.length-1]+r*2)
        else
          ys.push r
          shifted = yes
      else 
        xs.push curx
        ys.push (ys[ys.length-1]+r*2)
        shifted = no

    y0s = _.map ys, (y) -> y - r
    y1s = _.map ys, (y) -> y + r
    x0s = _.map xs, (x) -> x - r
    x1s = _.map xs, (x) -> x + r
    t = t.addColumn 'x', xs, gg.data.Schema.numeric, yes
    t = t.addColumn 'x0', x0s, gg.data.Schema.numeric, yes
    t = t.addColumn 'x1', x1s, gg.data.Schema.numeric, yes
    t = t.addColumn 'y', ys, gg.data.Schema.numeric, yes
    t = t.addColumn 'y0', y0s, gg.data.Schema.numeric, yes
    t = t.addColumn 'y1', y1s, gg.data.Schema.numeric, yes

    domain = [_.min(y0s), _.max(y1s)]
    sets = _.uniq pairtable.getMD().getColumn 'scales'
    for set in sets
      s = set.get 'y', gg.data.Schema.numeric
      s.domain domain
      s.range [Math.max(domain[0], s.range()[0]), Math.min(domain[1], s.range()[1])]
      s.frozen = yes

    new gg.data.PairTable(t, pairtable.getMD())

