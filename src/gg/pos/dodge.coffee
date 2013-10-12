#<< gg/pos/position


class gg.pos.Dodge extends gg.pos.Position
  @ggpackage = "gg.pos.Dodge"
  @aliases = ["dodge"]

  parseSpec: ->
    super
    @params.put "padding", _.findGoodAttr @spec, ['pad', 'padding'], 0.05

  inputSchema: -> ['x', 'x0', 'x1', 'group']


  compute: (pairtable, params) ->
    table = pairtable.getTable()
    table = gg.data.Transform.transform table, { '_base': (row) -> [row.get('x0'),row.get('x1')]}
    partitions = table.partition '_base'

    maxGroup = _.mmax partitions, (p) -> p.nrows()
    groupcol = _.uniq _.map(table.getColumn('group'), String)
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

      gg.data.Transform.transform group,
        x: newx
        x0: (row) -> newx(row) - (1.0-padding)*neww(row)/2
        x1: (row) -> newx(row) + (1.0-padding)*neww(row)/2


    table = new gg.data.MultiTable null, groups
    new gg.data.PairTable table, pairtable.getMD()

