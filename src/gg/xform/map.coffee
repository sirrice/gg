#<< gg/wf/node

# This class is a gg.core.XForm in signature only (ala duck typing) --
# any XForm can have mappers but not the other way around.
#
# gg.xform.Mapper performs a schema transformation.  It's spec is:
#
# {
#   name: STRING
#   aes: {
#     target-col-name: MAPSPEC
#   }
# }
#
# or 
# 
# { 
#   name: STRING
#   params:
#     aes: 
#       target-col-name: MAPSPEC
#  }
#
# MAPSPEC is:
#
# 1) attribute name
# 2) object of [target-col-name: MAPSPEC] pairs
# 3) function: (row) -> object
# 4) annotated function: 
#    {
#     f: (args...) ->
#     args: ["attr", ...., "attr"]
#    }
#    args is a list of table columns passed as arguments to f
# 5) "{ ECMAPSCRIPT }" will use eval() to transform into function
#
# 
# Provenance mappings can be automatically extracted from MAPSPECs 
# 1-4 and must be foresaken for 5
#
class gg.xform.Mapper extends gg.wf.Exec
  @ggpackage = "gg.xform.Mapper"
  @log = gg.util.Log.logger @ggpackage, 'map'
  @attrs = [
    "mapping", "map", "aes", 
    "aesthetic", "aesthetics"
  ]

  constructor: ->
    super

  parseSpec: ->
    @params.ensureAll
      mapping: [gg.xform.Mapper.attrs, {}]
      inverse: [[], @spec.inverse or {}]

    @params.putAll
      inputSchema: @inputSchema
      outputSchema: @outputSchema
    @params.ensure 'klassname', [], @constructor.ggpackage
    super


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
    mapping = _.findGoodAttr spec, gg.xform.Mapper.attrs, null
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



