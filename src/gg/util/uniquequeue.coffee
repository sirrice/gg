class gg.util.UniqQueue

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

