#<< gg/wf/node

# This class is a gg.core.XForm in signature only (ala duck typing) --
#
# Any XForm can have mappers but not the other way around.
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
class gg.xform.Mapper extends gg.wf.SyncExec
  @ggpackage = "gg.xform.Mapper"
  @log = gg.util.Log.logger @ggpackage, 'map'
  @attrs = [
    "mapping", "map", "aes", 
    "aesthetic", "aesthetics"
  ]

  parseSpec: ->
    @params.ensureAll
      mapping: [gg.xform.Mapper.attrs, {}]
      inverse: [[], @spec.inverse or {}]
    #@params.ensure 'klassname', [], @constructor.ggpackage
    super

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    mapping = params.get 'mapping'

    functions = @constructor.mappingToFunctions table, mapping
    table = gg.data.Transform.transform table, functions
    pt = new gg.data.PairTable table, pairtable.getMD()
    if 'group' in _.map(functions, ([col,f,t])->col)
      pt = pt.ensure ['group']
    pt

  @mappingToFunctions: (table, mapping) ->
    @log "transform: #{JSON.stringify mapping}"
    @log "table:     #{JSON.stringify table.schema.toString()}"

    groupable = null
    if 'group' of mapping
      groupable = mapping['group']
      unless _.isObject groupable
        groupable = {}
      mapping = _.omit mapping, 'group'
    else
      allcols = _.keys mapping
      cols = _.filter allcols, (c) -> gg.core.Aes.groupable c
      if cols.length > 0
        groupable = _.pick mapping, cols
    @log "groupable: #{JSON.stringify groupable}"

    functions = _.mappingToFunctions table, mapping
    if groupable?
      gFuncs = _.mappingToFunctions table, groupable
      groupf = ((gf) ->
        (row, idx) ->
          _.o2map gf, ([col, f, type]) -> 
            [col, f(row, idx)]
        )(gFuncs)
      functions.push ['group', groupf, gg.data.Schema.object]

    functions

  @fromSpec: (spec) ->
    spec = _.clone spec
    mapping = _.findGoodAttr spec, gg.xform.Mapper.attrs, null
    @log "fromSpec: #{JSON.stringify mapping}"

    unless mapping? and _.size(mapping) > 0
      return null 

    # aes should be the mapping
    inverse = spec.inverse
    unless spec.inverse?
      inverse = _.o2map mapping, (v,k) -> [v, k]
    spec.params = 
      aes: mapping
      inverse: inverse


    new gg.xform.Mapper spec



