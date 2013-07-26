#<< gg/wf/node

#
# A 1-to-1 mapping XForm.  A mapping is defined with a dictionary of
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
# under the covers, the map-specs are compiled into functions.
#
#
class gg.xform.Mapper extends gg.core.XForm
  @ggpackage = "gg.xform.Mapper"

  parseSpec: ->
    super

    @params.ensureAll
      mapping: [["map", "aes", "aesthetics"], @spec.aes or {}]
      inverse: [[], @spec.inverse or {}]
    @log "spec: #{@params}"


  compute: (data, params) ->
    table = data.table
    env = data.env
    @log "transform: #{JSON.stringify params.get 'mapping'}"
    @log "table:     #{JSON.stringify table.colNames()}"
    @log table.clone()

    # resolve aesthetic aliases in mapping
    functions = _.mappingToFunctions table, params.get('mapping')
    @log "functions: #{JSON.stringify functions}"
    table = table.transform functions, yes
    data.table = table
    data

  @fromSpec: (spec) ->
    spec = _.clone spec
    attrs = [
      "mapping", "map", "aes", 
      "aesthetic", "aesthetics"
    ]
    mapping = _.findGoodAttr spec, attrs, null
    @log "fromSpec: #{JSON.stringify mapping}"

    unless mapping? and _.size(mapping) > 0
      return null 


    # aes should be the mapping
    inverse = spec.inverse
    unless spec.inverse?
      inverse = {}
      _.each mapping, (val, key) -> 
        inverse[val] = key
    spec.params = 
      aes: mapping
      inverse: inverse


    new gg.xform.Mapper spec



