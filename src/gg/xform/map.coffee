#<< gg/wf/node


class gg.xform.Mapper extends gg.wf.SyncExec
  @ggpackage = "gg.xform.Mapper"
  @log = gg.util.Log.logger @ggpackage, 'map'
  @attrs = [
    "mapping", "map", "aes", 
    "aesthetic", "aesthetics"
  ]

  parseSpec: ->
    @params.put 'aes', @spec.aes
    super

  compute: (pt, params) ->
    table = pt.left()
    aes = params.get 'aes'

    functions = _.mappingToFunctions table, aes
    table = table.project functions, yes
    pt.left table

    if 'group' in _.map(functions, (desc)->desc.alias)
      pt = pt.ensure ['group']
    pt

  # extract/infer spec for grouping
  #
  # e.g., if "group" is not specified but "fill" is mapped and is of type categorical or identity, 
  #       then infer as a group
  #
  @groupSpec: (aes) ->
    keys = []
    desc = null
    groupable = {}

    if 'group' of aes 
      groupable = aes['group']
      keys = ['group']
    else
      keys = _.filter _.keys(aes), gg.core.Aes.groupable
      if keys.length > 0
        groupable = _.pick aes, keys

    {
      group: groupable
      cols: keys
    }

  @fromSpec: (spec) ->
    aes = spec.aes
    @log "fromSpec: #{JSON.stringify aes}"
    unless aes? and _.size(aes) > 0
      return null

    new gg.xform.Mapper spec



