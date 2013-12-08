#<< gg/stat/stat

class gg.stat.Sort extends gg.core.XForm
  @ggpackage = "gg.stat.Sort"
  @aliases = ['sort', 'sorted']

  parseSpec: ->
    super
    config = 
      cols: 
        names: ["col", "cols", "attr", "attrs"]
        default: ['y']
        f: (vals) -> _.flatten [vals]
      reverse:
        names: ['reversed', 'invert']
        default: no

    params = gg.parse.Parser.extractWithConfig @spec, config
    params.keys = ['facet-x', 'facet-y', 'layer', 'group']
    @params.putAll params

  inputSchema: (pairtable, params) -> params.get 'cols'

  compute: (pairtable, params) ->
    table = pairtable.left()
    reverse = params.get 'reverse'
    cols = params.get 'cols'
    table = table.orderby cols, reverse
    pairtable.left table
    pairtable
