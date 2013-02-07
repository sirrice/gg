@cross = (arr1, arr2) ->
    ret = []
    _.map arr1, (a1, i) ->
        _.map arr2, (a2, j) ->
            ret.push { x: a1, y: a2, i:i, j:j }
    ret

@attributeValue = (layer, aes, defaultVal, args...) ->
    if aes of layer.mappings
        (d) -> layer.scaledValue d, aes, args...
    else
        (d) -> defaultVal
@attrVal = @attributeValue

@groupData = (data, groupBy) ->
    if not groupBy? then [data] else _.groupBy data, groupBy

@splitByGroups = (data, group, variable) ->
    groups = {}
    if group
        _.each data, (d) =>
            g = d[group]
            groups[g] = [] if not groups[g]?
            groups[g].push d[variable]
    else
        groups['data'] = _.pluck data, variable
    groups



