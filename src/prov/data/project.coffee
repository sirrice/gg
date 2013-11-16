#<< gg/data/table


class gg.data.Projection extends gg.data.Table
  # @param mappings dictionary of
  #    col: 
  #      f: (row) ->  or (colval) ->
  #      type: (default: "row") | "col"
  #      cols: [ list of cols accessed ]
  #
  constructor: (@schema, @table, @mappings) ->
    @mappings = _.o2map @mappings, (desc, col) ->
      if desc.type == 'col'
        desc.f = (row, idx) -> desc.f row.get(col, idx)
        desc.cols = [col]
      else
        desc.type = 'row'
      desc.cols = _.flatten [desc.cols]


  iterator: ->
    class Iter
      constructor: (@schema, @table, @mappings) ->
        @iter = @table.iterator()

      reset: -> @iter.reset()

      next: ->
        row = @iter.next()
        newrow = new gg.data.Row @schema
        _.each @mappings, (desc, col) ->
          val = desc.f row
          newrow.set col, val
        newrow

      hasNext: -> @iter.hasNext()
      close: -> @iter.close()
    new Iter @schema, @table, @mappings



