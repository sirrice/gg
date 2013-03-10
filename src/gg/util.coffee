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

findGood = (list) -> _.find list, (v)->v

class gg.UniqQueue

    constructor: (args=[]) ->
        @list = []
        @id2item = {}
        _.each args, (item) => @push item


    push: (item) ->
        key = @key item
        unless key of @id2item
            @list.push item
            @id2item[key] = yes
        @

    pop: ->
        if @list.length == 0
            throw Error("list is empty")
        item = @list.shift()
        key = @key item
        delete @id2item[key]
        item

    length: -> @list.length
    empty: -> @length() is 0

    key: (item) ->
        if item?
            if _.isObject item
                if 'id' of item
                    item.id
                else
                    item.toString()
            else
                "" + item
        else
            null

