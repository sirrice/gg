#<< gg/data/table

# Schema == shared columns
class gg.data.PairTable 

  constructor: (@table=null, @md=null) ->
    @table ?= new gg.data.RowTable(new gg.data.Schema())
    @md ?= new gg.data.RowTable(new gg.data.Schema())

    @tableOnlyCols = _.filter @cols, (col) =>
      @table.has(col) and not @md.has(col)
    @mdOnlyCols = _.filter @cols, (col) =>
      not @table.has(col) and @md.has(col)

    @types = _.map @sharedCols, (col) => @table.schema.type col
    @schema = new gg.data.Schema @sharedCols, @types
    @log = gg.util.Log.logger @constructor.ggpackage, 'pairtable'


  sharedCols: ->
    tSchema = @tableSchema()
    mSchema = @mdSchema()
    cols = _.uniq _.flatten [tSchema.cols, mSchema.cols]
    sharedCols = _.filter cols, (col) =>
      (tSchema.has(col) and mSchema.has(col) and 
       (tSchema.type(col) == mSchema.type(col)))
    sharedCols

  partition: (joincols, type='outer') ->
    joincols = _.flatten [joincols]
    #joincols = _.intersection joincols, @sharedCols()
    ps = gg.data.Transform.partitionJoin @getTable(), @getMD(), joincols
    _.map ps, (o) -> 
      p = o['table']
      p

  # partition on _all_ of the shared columns
  # 
  # enforces invariant: each md should have a _single_ row
  fullPartition: (type='outer') -> 
    klass = @getMD().klass()
    partitions = @partition @sharedCols()
    partitions = _.map partitions, (p) =>
      table = p.getTable()
      md = p.getMD()
      if table.nrows() == 0
        if table.schema.cols.length == 0 and @tableSchema().cols.length > 0
          console.log(table)
          console.log(md)
          console.log(@)
          throw Error("full partition created diff schemas")
      if md.nrows() == 0
        row = new gg.data.Row(@mdSchema().clone())
        row = row.merge table.get(0).project(@sharedCols())
        md = klass.fromArray [row], @mdSchema().clone()
        new gg.data.PairTable table, md
      else if md.nrows() > 1
        #@log.warn "fullpartition: md.nrows (#{md.nrows()}) != 1.\t#{md.raw()}"
        p
      else
        p
    partitions

  # ensures there MD tuples for each unique combination of keys
  # if MD partition has records, clone any record and overwrite keys
  # otherwise use MD schema to create new record
  ensure: (cols=[]) ->
    cols = _.flatten [cols]
    sharedCols = _.filter cols, (col) => @md.schema.has col
    restCols = _.reject cols, (col) => @md.schema.has col
    unknownCols = _.reject restCols, (col) => @table.schema.has col
    restCols = _.filter restCols, (col) => @table.schema.has col
    if unknownCols.length > 0
      @log.warn "ensure dropping unknown cols: #{unknownCols}"

    klass = @getMD().klass()

    newMdSchema = @mdSchema()
    newMdSchema.merge @tableSchema().project(restCols)
    ps = @partition sharedCols
    newpartitions = []

    for p in ps
      t = p.getTable()
      md = p.getMD()


      if md.nrows() > 0
        createCopy = () => md.fastEach (row) -> row.clone()
      else if @md.nrows() > 0
        createCopy = () => [@md.get(0).clone()]
      else
        createCopy = () -> [new gg.data.Row(new gg.data.Schema())]


      subpartitions = t.partition restCols

      for sp in subpartitions
        keyschema = sp.schema.project restCols
        keyrow = new gg.data.Row keyschema
        for col in keyschema.cols
          keyrow.set col, sp.get(0, col)

        rows = _.map createCopy(), (row) -> row.merge keyrow
        newmd = klass.fromArray rows, newMdSchema
        newpartitions.push new gg.data.PairTable(sp, newmd)

    new gg.data.TableSet newpartitions
  
  tableSchema: -> @table.schema
  mdSchema: -> @md.schema
  getTable: -> @table
  getMD: -> @md
  clone: -> new gg.data.PairTable @getTable().clone(), @getMD().clone()
