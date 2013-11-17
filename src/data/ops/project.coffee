#<< data/table


class data.ops.Project extends data.Table
  # @param mappings list of
  #    alias: colname | [col, col..]
  #
  #         if alias is a list, then f is expected to return a dictionary 
  #         with alias keys, or null if absent
  #
  #    f: (row) ->  |  (col, ...) ->
  #
  #    type: schema type     (default: schema.object)
  #
  #    cols: '*' | [list of col args to f ] 
  #
  #         '*'  : f accepts row as argument (default)
  #         [..] : f accepts a list of column values as args
  #
  #   
  #
  constructor: (@table, @mappings) ->
    @mappings = _.map @mappings, (desc) =>
      throw Error("mapping must has an alias: #{desc}") unless desc.alias?
      desc.cols ?= '*'
      desc.cols = _.flatten [desc.cols] unless desc.cols == '*'
      desc.type ?= data.Schema.object
      if _.isArray desc.alias
        if _.isArray desc.type
          unless desc.type.lenghth == desc.alias.length
            throw Error "alias and type lens don't match: #{desc.alias} != #{desc.type}"
        else
          desc.type = _.times desc.alias.length, () -> desc.type

      if desc.cols != '*' and _.isArray desc.cols
        desc.cols = _.flatten [desc.cols]
        desc.f = ((f, cols) ->
          (row, idx) ->
            args = _.map cols, (col) -> row.get(col)
            f.apply f, args
          )(desc.f, desc.cols)
      else
        desc.cols = _.clone @table.schema.cols

      desc

    cols = _.flatten _.map(@mappings, (desc) -> desc.alias)
    types = _.flatten _.map(@mappings, (desc) -> desc.type)
    @schema = new data.Schema cols, types

  iterator: ->
    class Iter
      constructor: (@schema, @table, @mappings) ->
        @iter = @table.iterator()
        @idx = -1

      reset: -> 
        @iter.reset()
        @idx = -1

      next: ->
        @idx += 1
        row = @iter.next()
        newrow = new data.Row @schema
        for desc in @mappings
          if _.isArray desc.alias
            o = desc.f row, @idx
            for col in desc.alias
              newrow.set col, o[col]
          else
            val = desc.f row, @idx
            newrow.set desc.alias, val
        newrow

      hasNext: -> @iter.hasNext()
      close: -> @iter.close()
    new Iter @schema, @table, @mappings



