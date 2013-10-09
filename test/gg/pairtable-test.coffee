require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "pairtable.js"
Schema = gg.data.Schema
Transform = gg.data.Transform
Table = gg.data.Table




createSimplePairTable = -> 
  left = Table.fromArray [
    { x: 1, y: 1, l: 1}
    { x: 1, y: 2, l: 1}
    { x: 2, y: 2, l: 3}
    { x: 2, y: 3, l: 2}
  ]
  right = Table.fromArray [
    { x: 1, l: 1, z: 0 }
    { x: 1, l: 3, z: 1 }
    { x: 2, l: 2, z: 2 }
    { x: 2, l: 1, z: 3 }
  ]

  new gg.data.PairTable left, right

createSimpleTableSet = ->
  left = Table.fromArray [
    { x: 1, y: 1, l: 1}
    { x: 1, y: 2, l: 1}
  ]
  right = Table.fromArray [
    { x: 1, l: 1, z: 0 }
    { x: 1, l: 3, z: 1 }
  ]
  pt1 = new gg.data.PairTable left, right

  left = Table.fromArray [
    { x: 2, y: 2, l: 3}
    { x: 2, y: 3, l: 2}
  ]
  right = Table.fromArray [
    { x: 2, l: 2, z: 2 }
    { x: 2, l: 1, z: 3 }
  ]
  pt2 = new gg.data.PairTable left, right

  new gg.data.TableSet [pt1, pt2]

createEmptyMD = ->
  left = Table.fromArray [
    { x: 1, y: 1, l: 1}
    { x: 1, y: 2, l: 1}
    { x: 2, y: 2, l: 3}
    { x: 2, y: 3, l: 2}
  ]
  new gg.data.PairTable left


checkEnsure =
  "when ensured on x,y":
    topic: (ptable) -> ptable.clone().ensure ['x', 'y']
    "md": 
      topic: (tset) -> tset.getMD()
      "has 8 rows": (md) -> assert.equal md.nrows(), 8
      "correct number of ys": (md) ->
        ps = md.partition 'y'
        for p in ps
          if p.get(0, 'y') in [1, 3]
            assert.equal p.nrows(), 2
          else 
            assert.equal p.nrows(), 4

  "when ensured on nothing":
    topic: (ptable) -> ptable.clone().ensure []
    "md":
      topic: (tset) -> tset.getMD()
      "has 4 rows": (md) -> assert.equal md.nrows(), 4




suite.addBatch
  "ensure empty md":
    topic: createEmptyMD
    "when ensured on nothing":
      topic: (ptable) -> ptable.clone().ensure []
      "md":
        topic: (tset) -> tset.getMD()
        "has 1 row": (md) ->
          assert.equal md.nrows(), 1

  "ensure pairtable":
    _.extend({topic: createSimplePairTable},
      checkEnsure)

  "ensure tableset":
    _.extend({topic: createSimpleTableSet},
      checkEnsure)


  "pair table with dups": 
    topic: ->
      leftrows = _.times 10, (i) -> 
        { id: i % 2, a: i%5, j1: i%2, j2: i%3 }
      rightrows = _.times 10, (i) -> 
        { id: i % 2, b: "b-#{i%4}", j1: i%2, j2:i%3 }
      left = Table.fromArray leftrows
      right = Table.fromArray rightrows
      new gg.data.PairTable left, right

    "when fully partitioned should fail": (table) ->
      assert.throws table.fullPartition



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

    "when fully partitioned":
      topic: (table) ->
        partitions = table.fullPartition()
        assert.equal partitions.length, 10


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
        { id: i+10, y: i%5, j1: i%2, j2: i%3 }
      rightrows = _.times 10, (i) -> 
        { id: i+10, z: "b-#{i%4}", j1: i%2, j2:i%3 }
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


    "when fully partitioned":
      topic: (table) ->
        partitions = table.fullPartition()
        assert.equal partitions.length, 20


suite.export module
