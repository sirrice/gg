#<< gg/core/xform
#<< gg/data/schema

class gg.geom.reparam.Text extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Text"


  inputSchema: -> ['x', 'y', 'text']

  outputSchema: (pairtable, params) ->
    table = pairtable.getTable()
    schema = table.schema.clone()
    _.each ["x0", "x1", "y0", "y1"], (col) ->
      unless schema.has col
        schema.addColumn col, numeric
    schema

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    cache = {}
    getSize = (text) ->
      len = String(text).length
      unless len of cache
        cache[len] = _.textSize(text)
      return cache[len]


    cols = ['x', 'y', 'text']
    mapping =
      x0: (row) -> row.get 'x'
      x1: (row) -> row.get('x') + getSize(row.get 'text').w
      y0: (row) -> row.get 'y'
      y1: (row) -> row.get 'y' + getSize(row.get 'text').h
    mapping = _.map mapping, (f,k) -> [k,f,gg.data.Schema.numeric]
    table = gg.data.Transform.transform table,mapping 

    new gg.data.PairTable table, pairtable.getMD()


