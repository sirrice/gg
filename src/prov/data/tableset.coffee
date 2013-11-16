

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

