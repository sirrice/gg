# options
#
# 1. iterator model
#    efficient during execution
#    how to/when to generate prov
#
# 2. block execution model
#    generate prov is "easy"
#    multiple copies of tables
#
class gg.data.Op
  constructor: (@t) ->

  nrows: -> @t.nrows()

  get: (idx, col) -> @t.get idx, col

  raw: -> @t.raw()
  
  each: (f, n) ->  @t f, n


class gg.data.Partition extends gg.data.Op
  constructor: (table, keys) ->

