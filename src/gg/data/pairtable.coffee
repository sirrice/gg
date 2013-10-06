#<< gg/data/table

# Schema == shared columns
class gg.data.PairTable 

  constructor: (@table, @md) ->
    @cols = _.uniq _.flatten [@table.cols(), @md.cols()]
    @sharedCols = _.filter @cols, (col) =>
      (@table.has(col) and 
        @md.has(col) and 
        (@table.schema.type(col) == @md.schema.type(col)))
    @tableOnlyCols = _.filter @cols, (col) =>
      @table.has(col) and not @md.has(col)
    @mdOnlyCols = _.filter @cols, (col) =>
      not @table.has(col) and @md.has(col)

    @types = _.map @sharedCols, (col) => @table.schema.type col
    @schema = new gg.data.Schema @sharedCols, @types


  partition: (joincols) ->
    ps = gg.data.Transform.partitionJoin @table, @md, joincols
    _.map ps, (o) -> o['table']
