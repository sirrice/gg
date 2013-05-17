
#
# 1 to 1 mapping function
#
# 1. key lookups
# 2. function transformations
# 3. An evaled string where the env is populated with variables defined by the tuple
#
# {
#   attr1: "key"
#   attr2: (row) -> newv
#   attr3: "x + y*5"
#   x:     (x, row) -> x'
# }
#
class gg.wf.Map extends gg.wf.Exec

  constructor: (@spec) ->
    @mapping = _.findGood [@spec.aes, @spec.map, @spec.mapping]


  compute: (table, env, node) ->
    table.transform @mapping
