#<< data/table


class data.ops.Project extends data.Table
  # @param mappings dictionary of
  #    col: 
  #      f: (row) ->  or (colval) ->
  #      type: schema type (default: schema.object)
  #      cols: [ list of cols accessed ] | "*" to pass in row
  #
  constructor: (@table, @mappings) ->
    @mappings = _.o2map @mappings, (desc, col) =>
      desc.cols ?= '*'
      desc.type ?= data.Schema.object

      if desc.cols != '*' and _.isArray desc.cols
        desc.cols = _.flatten [desc.cols]
        desc.f = ((f, cols) ->
          (row, idx) ->
            args = _.map cols, (col) -> row.get(col)
            f.apply f, args
          )(desc.f, desc.cols)
      else
        desc.cols = _.clone @table.schema.cols


      [col, desc]

    cols = _.keys @mappings
    types = _.map _.values(@mappings), (desc) -> desc.type
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
        _.each @mappings, (desc, col) ->
          val = desc.f row, @idx
          newrow.set col, val
        newrow

      hasNext: -> @iter.hasNext()
      close: -> @iter.close()
    new Iter @schema, @table, @mappings



