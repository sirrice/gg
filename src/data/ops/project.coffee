#<< data/table


class data.ops.Project extends data.Table
  # @param mappings dictionary of
  #    col: 
  #      f: (row) ->  or (colval) ->
  #      type: (default: "row") | "col"
  #      cols: [ list of cols accessed ]
  #
  constructor: (@schema, @table, @mappings) ->
    @mappings = _.o2map @mappings, (desc, col) ->
      if desc.type == 'col'
        desc.f = ((f) ->
          (row, idx) -> f row.get(col, idx)
        )(desc.f)
        desc.cols = [col]
      else
        desc.type = 'row'
      desc.cols = _.flatten [desc.cols]
      [col, desc]


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



