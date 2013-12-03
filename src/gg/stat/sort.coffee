#<< gg/stat/stat

class gg.stat.Sort extends gg.stat.Stat
  @ggpackage = "gg.stat.Sort"
  @aliases = ['sort', 'sorted']

  parseSpec: ->
    super
    cols = ["col", "cols", "attr", "attrs", "aes", "aess" ]
    cols = _.findGoodAttr @spec, cols, []
    cols = _.flatten [cols] 
    reverse = _.findGood @spec, ['reverse', 'invert'], no
    @params.putAll
      cols: cols
      reverse: reverse
      keys: ['facet-x', 'facet-y', 'layer', 'group']

  inputSchema: (pairtable, params) -> params.get 'cols'

  compute: (pairtable, params) ->
    table = pairtable.left()
    reverse = params.get 'reverse'
    cols = params.get 'cols'
    table = table.orderby cols, reverse
    pairtable.left table
    pairtable
