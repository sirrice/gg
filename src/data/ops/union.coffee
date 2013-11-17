#<< data/table

class data.ops.Union extends data.Table

  # @param arguments are all table or list of tables
  constructor: () ->
    @tables = _.compact _.flatten arguments
    unless @tables.length > 1
      throw Error "Union expects >1 tables.  got #{@tables.length}"
    @schema = @tables[0].schema
    @ensureSchema()

  ensureSchema: ->
    for table in @tables
      unless @schema.equals table.schema
        throw Error "Union table schemas don't match: #{@schema.toString()}  != #{table.schema.toString()}"

  iterator: ->
    class Iter
      constructor: (@schema, @tables) ->
        @reset()

      reset: -> 
        @tableidx = -1
        @iter = null

      next: -> 
        throw Error("iterator has no more elements") unless @hasNext()
        @iter.next()

      hasNext: -> 
        if @tableidx >= @tables.length
          return no

        until @iter? and @iter.hasNext()
          @tableidx += 1
          if @tableidx >= @tables.length
            return no
          @iter = @tables[@tableidx].iterator()

        yes

      close: -> 
        @iter.close() if @iter?
        @reset()

    new Iter @schema, @tables


