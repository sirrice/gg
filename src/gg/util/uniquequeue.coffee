class gg.util.UniqQueue

  constructor: (args=[], key=null) ->
    @list = []
    @id2item = {}
    _.each args, (item) => @push item
    @_key = key or gg.util.UniqQueue.defaultKeyF

  # Get/set key function
  # @param key the new key function
  # @returns current key function
  key: (key) ->
    if key?
      @_key = key
    @_key

  push: (item) ->
    key = @key item
    unless key of @id2item
      @list.push item
      @id2item[key] = yes
    @

  pop: ->
    if @length() is 0
      throw Error("list is empty")
    item = @list.shift()
    key = @key item
    delete @id2item[key]
    item

  peek: ->
    if @length() is 0
      throw Error("list is empty")
    @list[0]


  length: -> @list.length
  empty: -> @length() is 0

  @defaultKeyF: (item) ->
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

