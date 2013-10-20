#<< gg/scale/factory
#

#
#
# Manage a graphic/pane/layer's set of scales
# a Wrapper around {aes -> {type -> scale} } + utility functions
#
# lazily instantiates scale objects as they are requests.
# uses internal scalesFactory for creation
#
class gg.scale.MergedSet
  @ggpackage = 'gg.scale.MergedSet'
  
  constructor: (@sets=[]) ->
    @mapping = {}
    @setup()

  key: (col, type, klassName) ->
    JSON.stringify([col, String(type), klassName])

  setup: ->
    mapping = {} # (scaleclass, type, aes) -> [ scales to merge ]
    for set in @sets
      for s in set.scalesList()
        key = @key s.aes, s.type, s.constructor.name
        mapping[key] = [] unless key of mapping
        mapping[key].push s

    @mapping = _.o2map mapping, (ss, key) ->
      s = ss[0].clone()
      for other in _.rest(ss)
        s.mergeDomain other.domain()
      [key, s]

  contains: (aes, type, klassName) ->
    @key(aes, type, klassName) of @mapping

  get: (aes, type, klassName) ->
    @mapping[@key aes, type, klassName]

  toString: ->
    ss = _.map @mapping, (s, k) -> 
      k + "\t->\t" + s.toString()
    ss.join('\n')




