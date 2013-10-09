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

  # ensures there MD tuples for each unique combination of keys
  # if MD partition has records, clone any record and overwrite keys
  # otherwise use MD schema to create new record
  ensure: (cols) ->
    sharedCols = _.filter cols, (col) => @md.schema.has col
    restCols = _.reject cols, (col) => @md.schema.has col

    ps = @partition sharedCols
    newpartitions = []

    for p in ps
      t = p.getTable()
      md = p.getMD()

      if md.nrows() > 0
        createCopy = () => md.each (row) -> row.clone()
      else if @md.nrows() > 0
        createCopy = () => [@md.get(0).clone()]
      else
        createCopy = () -> new gg.data.Row(new gg.data.Schema)

      subpartitions = t.partition cols

      for t in subpartitions
        keyschema = t.schema.project cols
        keyrow = new gg.data.Row keyschema
        for col in cols
          keyrow.set col, t.get(0, col)

        rows = _.map createCopy(), (row) -> row.merge keyrow
        newmd = gg.data.RowTable.fromArray rows
        newpartitions.push new gg.data.PairTable(t, newmd)

    new gg.data.TableSet newpartitions
  
  tableSchema: -> @table.schema
  mdSchema: -> @md.schema
  getTable: -> @table
  getMD: -> @md
  clone: -> new gg.data.PairTable @getTable().clone(), @getMD().clone()
