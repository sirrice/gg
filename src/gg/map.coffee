#<< gg/wf/node

#
# A mapping XForm.  A mapping is defined with a dictionary of
#
#   target-col-name: map-spec
#
# where map-spec is one of:
#
# 1) "attribute"
# 2) object
# 3) function: (tuple) -> object
# 4) ecmascript expression: will use eval() to transform into function
#
class gg.Mapper extends gg.XForm
  constructor: (@g, @mapping) ->
    @spec = {}
    @parseSpec()
    super @g, @spec

    @type = "mapper"
    @name = findGood [@spec.name, "mapper-#{@id}"]

  parseSpec: ->
    #@mapping = findGood [@spec.mapping, @spec.map, @spec.aes, {}]
    @aesthetics = _.keys @mapping
    @spec.f = (table) => table.transform @mapping, no
    @inverse = {}
    _.each @mapping, (val, key) => @inverse[val] = key

  compute: (table, env, node) ->
    table.transform @mapping

  invertColName: (outColName) -> @inverse[outColName]

