require "../env"
events = require "events"
vows = require "vows"
assert = require "assert"



suite = vows.describe "pairtable.js"
Schema = gg.data.Schema
Transform = gg.data.Transform
Table = gg.data.Table

check =
  "when run": 
    topic: (node) ->
      promise = new events.EventEmitter
      node.on 'output', (id, idx, tset) ->
        promise.emit 'success', tset
      node.on 'error', (errmsg) ->
        promise.emit 'error', errmsg
      node.setInput 0, new gg.data.PairTable()
      node.run()
      promise

    "is not null": (result) ->
      assert result?
    "is a pairtable": (result) ->
      assert.instanceOf result, gg.data.PairTable
    "# rows correct": (result) ->
      assert.equal 10, result.getTable().nrows()
      assert.equal 0, result.getMD().nrows()




tablesource = 
  topic: ->
    rows = _.times 10, (i) -> {a: i, b: i}
    table = gg.data.Table.fromArray rows

    new gg.wf.TableSource
      params:
        table: table
_.extend tablesource, check


rowsource =
  topic: ->
    rows = _.times 10, (i) -> {a: i, b: i}
    new gg.wf.RowSource
      params:
        rows: rows
_.extend rowsource, check


sqlsource =
  topic: ->
    new gg.wf.SQLSource
      params:
        uri: "postgresql://localhost:5432/fec12"
        q: "select * from expenses limit 10"
_.extend sqlsource, check



suite.addBatch 
  sqlsource: sqlsource
  tablesource: tablesource
  rowsource: rowsource

suite.export module

