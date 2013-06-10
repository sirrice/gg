
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
    super
    @type = "mapper"
    @name = _.findGood [@spec.name, "mapper-#{@id}"]

    @params.ensureAll
      mapping: [ ['aes', 'map', 'mapping'], {} ]

  compute: (table, env, params) ->
    mapping = params.get 'mapping'
    mapping = gg.util.mappingToFunctions table, mapping
    table.transform mapping
