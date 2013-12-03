#<< gg/pos/position


class gg.pos.Dodge extends gg.core.XForm
  @ggpackage = "gg.pos.Dodge"
  @aliases = ["dodge"]

  defaults: ->
    x0: 'x'
    x1: 'x'

  parseSpec: ->
    super
    @params.put 'keys', ['layer']
    @params.put "padding", _.findGoodAttr @spec, ['pad', 'padding'], 0.05

  inputSchema: -> ['x', 'x0', 'x1', 'group']


  compute: (pairtable, params) ->
    table = pairtable.left()

    groups = table.partition('group').orderby('group')
    ngroups = groups.nrows()
    padding = params.get 'padding'
    
    groups = groups.map (row, idx) ->
      group = row.get 'table'

      neww = (x1, x0) -> (x1 - x0) / ngroups
      newx = (x1, x0, x) -> 
        width = x1 - x0
        newWidth = width / ngroups
        x - width/2 + idx*newWidth + newWidth/2

      mapping = [
        { 
          alias: 'x'
          f: newx
          type: data.Schema.numeric 
          cols: ['x1', 'x0', 'x']
        }
        { 
          alias: 'x0'
          f: (x1, x0, x) ->
            newx(x1, x0, x) - (1.0 - padding)*neww(x1, x0)/2
          type: data.Schema.numeric
          cols: ['x1', 'x0', 'x']
        }
        { 
          alias: 'x1'
          f: (x1, x0, x) ->
            newx(x1, x0, x) + (1.0 - padding)*neww(x1, x0)/2
          type: data.Schema.numeric
          cols: ['x1', 'x0', 'x']
        }
      ]
      group.project mapping, yes

    table = new data.ops.Union groups
    pairtable.left table
    pairtable

