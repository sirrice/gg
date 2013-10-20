#<< gg/pos/position


class gg.pos.Dodge extends gg.core.XForm
  @ggpackage = "gg.pos.Dodge"
  @aliases = ["dodge"]

  defaults: ->
    group: {}
    x0: 'x'
    x1: 'x'

  parseSpec: ->
    super
    @params.put 'keys', ['facet-x', 'facet-y', 'layer']
    @params.put "padding", _.findGoodAttr @spec, ['pad', 'padding'], 0.05

  inputSchema: -> ['x', 'x0', 'x1', 'group']


  compute: (pairtable, params) ->
    table = pairtable.getTable()
    partitions = table.partition ['x0', 'x1']

    nrows = _.map(partitions, (p) -> p.nrows())
    maxGroup = _.max(nrows)
    groupcol = _.uniq _.map(table.getColumn('group'), JSON.stringify)
    ngroups = groupcol.length
    groups = table.partition 'group'
    padding = params.get 'padding'
    
    groups = _.map groups, (group, idx) ->
      neww =(row) -> 
        width = row.get('x1') - row.get('x0')
        width / ngroups
 
      newx = (row) -> 
        width = row.get('x1') - row.get('x0')
        newWidth = width / ngroups
        row.get('x') - width/2 + idx*newWidth + newWidth/2

      mapping =
        x: newx
        x0: (row) -> newx(row) - (1.0-padding)*neww(row)/2
        x1: (row) -> newx(row) + (1.0-padding)*neww(row)/2
      mapping = _.map mapping, (f,k) -> [k,f,gg.data.Schema.numeric]
      gg.data.Transform.transform group, mapping

    table = new gg.data.MultiTable null, groups
    new gg.data.PairTable table, pairtable.getMD()

