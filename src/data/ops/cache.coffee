class data.ops.Cache
  constructor: (@table) ->
    @_cache = null
    @schema = @table.schema

  iterator: ->
    unless @_cache?
      @_cache = prov.data.Table.fromArray @table.rows(), @schema
    @_cache.iterator()

  
