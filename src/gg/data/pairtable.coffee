#<< gg/data/table

# Schema == shared columns
class gg.data.PairTable 

  constructor: (@table=null, @md=null) ->
    @table ?= new gg.data.RowTable(new gg.data.Schema())
    @md ?= new gg.data.RowTable(new gg.data.Schema())

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

  # ensures there are tuples for each enuque combination of keys
  ensure: (keys) ->
    throw Error
  
  getTable: -> @table
  getMD: -> @md
