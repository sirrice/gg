require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "pairtable.js"
Schema = gg.data.Schema
Transform = gg.data.Transform
Table = gg.data.Table

suite.addBatch
  "pair table": 
    topic: ->
      lschema = Schema.fromJSON
        id: Schema.numeric
        a: Schema.numeric
        j1: Schema.numeric
        j2: Schema.numeric
      rschema = Schema.fromJSON
        id: Schema.numeric
        b: Schema.ordinal
        j1: Schema.numeric
        j2: Schema.numeric
      leftrows = _.times 10, (i) -> 
        { id: i, a: i%5, j1: i%2, j2: i%3 }
      rightrows = _.times 10, (i) -> 
        { id: i, b: "b-#{i%4}", j1: i%2, j2:i%3 }
      left = Table.fromArray leftrows, lschema
      right = Table.fromArray rightrows, rschema

      new gg.data.PairTable left, right

    "when partitioned on j1":
      "has 2 partitions": (table) ->
        partitions = table.partition 'j1'
        assert.equal partitions.length, 2

  "table set": 
    topic: ->
      lschema = Schema.fromJSON
        id: Schema.numeric
        a: Schema.numeric
        j1: Schema.numeric
        j2: Schema.numeric
      rschema = Schema.fromJSON
        id: Schema.numeric
        b: Schema.ordinal
        j1: Schema.numeric
        j2: Schema.numeric
      leftrows = _.times 10, (i) -> 
        { id: i, a: i%5, j1: i%2, j2: i%3 }
      rightrows = _.times 10, (i) -> 
        { id: i, b: "b-#{i%4}", j1: i%2, j2:i%3 }
      left = Table.fromArray leftrows, lschema
      right = Table.fromArray rightrows, rschema

      ptable1 = new gg.data.PairTable left, right

      lschema = Schema.fromJSON
        id: Schema.numeric
        y: Schema.numeric
        j1: Schema.numeric
        j2: Schema.numeric
      rschema = Schema.fromJSON
        id: Schema.numeric
        z: Schema.ordinal
        j1: Schema.numeric
        j2: Schema.numeric
      leftrows = _.times 10, (i) -> 
        { id: i, y: i%5, j1: i%2, j2: i%3 }
      rightrows = _.times 10, (i) -> 
        { id: i, z: "b-#{i%4}", j1: i%2, j2:i%3 }
      left = Table.fromArray leftrows, lschema
      right = Table.fromArray rightrows, rschema

      ptable2 = new gg.data.PairTable left, right
      new gg.data.TableSet [ptable1, ptable2]

    "when partitioned on j1":
      "has 2 partitions": (table) ->
        partitions = table.partition 'j1'
        assert.equal partitions.length, 2

    "when partitioned on j1, j2":
      "has 6 parts": (table) ->
        partitions = table.partition ['j1', 'j2']
        assert.equal partitions.length, 6



suite.export module
