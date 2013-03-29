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
  constructor: (@g, @spec) ->
    super @g, @spec
    @parseSpec()

    @type = "mapper"
    @name = findGood [@spec.name, "mapper-#{@id}"]

  parseSpec: ->
    @mapping = findGood [@spec.mapping, @spec.map, @spec.aes, {}]
    console.log "mapper spec: #{JSON.stringify @mapping}"

    @aes = @aesthetics = _.keys @mapping
    @spec.aes = @mapping
    @inverse = {}
    _.each @mapping, (val, key) => @inverse[val] = key
    super

  compute: (table, env, node) ->
    console.log "transform: #{JSON.stringify @mapping}"
    console.log "table:     #{JSON.stringify table.colNames()}"
    table = table.clone()
    table.transform @mapping, yes
    table

  invertColName: (outColName) -> @inverse[outColName]

