#<< gg/data/table

class gg.data.PairTable extends gg.data.Table

  constructor: (@table, @md) ->
    @cols = _.uniq _.flatten [@table.schema.cols, @md.schema.cols]
    @sharedCols = _.filter cols, (col) =>
      @table.has(col) and @md.has(col)
    @tableOnlyCols = _.filter cols, (col) =>
      @table.has(col) and not @md.has(col)
    @mdOnlyCols = _.filter cols, (col) =>
      not @table.has(col) and @md.has(col)

    @types = []
    for col in @cols
      if col in @sharedCols
        unless @table.schema.type(col) is @md.schema.type(col)
          throw Error
      if @table.has col
        @types.push @table.schema.type(col)
      else
        @types.push @md.schema.type(col)

    @schema = new gg.data.Schema @cols, @types

