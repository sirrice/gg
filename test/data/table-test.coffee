require "../envdata"
vows = require "vows"
assert = require "assert"


suite = vows.describe "table.js"
Table = data.Table
Schema = data.Schema

makeTable = (n=10) ->
  os = _.times n, (i) -> {x:i, y: i*i, z: i+10}
  table = Table.fromArray os, null, "row"

schemaCheck = 
  "can be turned to json and parsed back": (table) ->
    table2 = table.clone()

    assert.deepEqual table.schema.toJSON(), table2.schema.toJSON()
    _.times table.nrows(), (idx) ->
      assert.equal table.get(idx, 'a'), table2.get(idx, 'a'), "a's should be equal: #{table.get(idx, 'a')} != #{table2.get(idx, 'a')}"

  "has correct schema": (table) ->
    schema = table.schema
    _.each ['a', 'b', 'c', 'id', 'nest'], (col) ->
      assert schema.has(col), "#{col} not found"
    _.each ['a', 'b', 'c'], (col) ->
      assert schema.isNumeric(col), "#{col} not numeric"


suite.addBatch
  "table":
    topic: makeTable

    "filtered": 
      topic: (table) -> table.filter (row) -> row.get('x') < 3
      "has 3 rows": (table) ->
        table.each (row) -> 
          assert.lt row.get('x'), 3


suite.export module
