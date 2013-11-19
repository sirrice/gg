#<< gg/core/xform

class gg.geom.reparam.Text extends gg.core.XForm
  @ggpackage = "gg.geom.reparam.Text"


  inputSchema: -> ['x', 'y', 'text']

  outputSchema: (pairtable, params) ->
    table = pairtable.left()
    schema = table.schema.clone()
    _.each ["x0", "x1", "y0", "y1"], (col) ->
      unless schema.has col
        schema.addColumn col, numeric
    schema

  compute: (pairtable, params) ->
    table = pairtable.left()
    cache = {}
    getSize = (text) ->
      len = String(text).length
      unless len of cache
        cache[len] = _.textSize(text)
      return cache[len]


    cols = ['x', 'y', 'text']
    mapping = [
      {
        alias: 'x0'
        f: _.identity
        type: data.Schema.numeric
        cols: 'x'
      }
      {
        alias: 'x1'
        f: (x, text) -> x + getSize(text).w
        type: data.Schema.numeric
        cols: ['x', 'text']
      }
      {
        alias: 'y0'
        f: _.identity
        type: data.Schema.numeric
        cols: 'y'
      }
      {
        alias: 'y1'
        f: (y, text) -> y + getSize(text).h
        type: data.Schema.numeric
        cols: ['y', 'text']
      }
    ]
    table = table.project mapping
    pairtable.left table
    pairtable

