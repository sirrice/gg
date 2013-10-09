

# Collection of PairTables
# Provides same APi as pairtable
class gg.data.TableSet extends gg.data.PairTable

  constructor: (@pairtables) ->

  checkSchema: (cols) ->
    for schema in @schemas()
      for col in cols
        unless schema.has col
          return no
    yes

  # can only partition on columns present in every table!
  partition: (cols) ->
    cols = _.compact _.flatten [cols]
    #unless @checkSchema cols
    #throw Error "cols #{cols.join(' ')} not in all schemas"
    
    keys = []
    lefts = {}
    rights = {}
    for table in @pairtables
      ps = gg.data.Transform.partitionJoin(
        table.getTable(), table.getMD(), cols
      )
      for p in ps
        key = p['key']
        lefts[key] = [] unless key of lefts
        lefts[key].push p['table'].table
        rights[key] = [] unless key of rights
        rights[key].push p['table'].md
        keys.push key


    # create new PairTable for each unique key
    keys = _.uniq keys
    ret = []
    for key in keys
      left = gg.data.Table.merge lefts[key]
      right = gg.data.Table.merge rights[key]
      pt = new gg.data.PairTable left, right
      ret.push pt
    ret


  ensure: (cols) ->
    new gg.data.PairTable(@getTable(), @getMD()).ensure(cols)

  tableSchema: -> gg.data.Schema.merge _.map(@pairtables, (pt) -> pt.tableSchema())
  mdSchema: -> gg.data.Schema.merge _.map(@pairtables, (pt) -> pt.mdSchema())
  getTable: ->
    tables = _.map @pairtables, (pt) -> pt.getTable()
    new gg.data.MultiTable null, tables

  getMD: ->
    tables = _.map @pairtables, (pt) -> pt.getMD()
    new gg.data.MultiTable null, tables

