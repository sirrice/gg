require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "debug.js"
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


log = (text) ->
  output = [
    '# rows: 4'
    'Schema: [["x",2],["y",2],["l",2]]'
    '[["x",1],["y",1],["l",1]]'
    '[["x",1],["y",2],["l",1]]'
    '[["x",2],["y",2],["l",3]]'
    '[["x",2],["y",3],["l",2]]'
  ]
  res = (text in output)
  assert res


suite.addBatch
  "stdout":
    "on pairtable":
      topic: createSimplePairTable
      "is correct": (pairtable) ->
        console.log pairtable.getTable().nrows()
        gg.wf.Stdout.print pairtable.getTable(), null, 10, log


    "on tableset":
      topic: createSimpleTableSet
      "is correct": (pairtable) ->
        gg.wf.Stdout.print pairtable.getTable(), null, 10, log

suite.export module
