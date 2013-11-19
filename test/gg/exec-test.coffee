require "../env"
events = require "events"
vows = require "vows"
assert = require "assert"



suite = vows.describe "exec.js"
Schema = data.Schema
Table = data.Table

check = 
  "when executed": 
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 10, (i) -> {a: i%2, b: i}
      table = data.Table.fromArray rows
      pt = new data.PairTable table
      pt = pt.ensure []
      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, pt
      node.run()
      promise

    "has 10 results": (pt) ->
      assert.equal pt.left().nrows(), 10

    "has correct 'attr1'": (pt) ->
      pt.left().each (row) ->
        v = row.get 'attr1'
        assert.lte v, 0, "attr1 #{v} should be <= 0"



createdexec = 
  topic: ->
    gg.wf.Exec.create (pairtable, params, cb) ->
      table = pairtable.left().project {
        alias: 'attr1'
        f: (a) -> -a
        cols: 'a'
      }
      pairtable = new data.PairTable table, pairtable.right()
      cb null, pairtable
_.extend createdexec, check

extendedexec = 
  topic: ->
    klass = class ExecKlass extends gg.wf.Exec
      compute: (pairtable, params, cb) ->
        table = pairtable.left()
        table = pairtable.left().project {
          alias: 'attr1'
          f: (a) -> -a
          cols: 'a'
        }
        pairtable = new data.PairTable table, pairtable.right()
        cb null, pairtable
    new klass
_.extend extendedexec, check

createAggExec = ->
  gg.wf.Exec.create ((pairtable, params, cb) ->
    t = pairtable.left()
    bcol = t.all 'b'
    total = _.sum bcol
    schema = t.schema.project 'a'
    schema.addColumn 'b', data.Schema.numeric
    row = { a:t.any('a'), b: total}

    t = data.Table.fromArray [row], schema
    pairtable = new data.PairTable t, pairtable.right()
    cb null, pairtable), {key: 'a'} 

createSyncExec = ->
  gg.wf.SyncExec.create  (pt, params) ->
    t = pt.left().setColVal 'z', 99
    new data.PairTable t, pt.right()

syncExec = 
  topic: createSyncExec
  "when run":
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 10, (i) -> {a: i%2, b: i}
      left = data.Table.fromArray rows
      right = data.Table.fromArray [{a: 0}, {a: 1}]
      pt = new data.PairTable left, right
      node.on 'output', (id, idx, pt) ->
        promise.emit 'success', pt
      node.setInput 0, pt
      node.run()
      promise

    "has z column": (pt) ->
      pt.left().each (row) ->
        assert.equal row.get('z'), 99



aggexecPairTable = 
  topic: createAggExec
  "when executed on pairtable": 
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 10, (i) -> {a: i%2, b: i}
      table = data.Table.fromArray rows
      pt = new data.PairTable table
      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, pt
      node.run()
      promise

    "has 2 rows": (pt) ->
      assert.equal pt.left().nrows(), 2

    "b totals": (pt) ->
      t = pt.left()
      rows = t.all()
      assert.equal rows[0].get('b'), 20
      assert.equal rows[1].get('b'), 25

aggexecTSet = 
  topic: createAggExec
  "when executed on tableset": 
    topic: (node) ->
      promise = new events.EventEmitter
      left = data.Table.fromArray(_.times 5, (i) ->
        {a: i%2, b: i})
      right = data.Table.fromArray [{a:0}]
      pt1 = new data.PairTable left, right
      rows = _.times 5, (i) -> {a: (i+5)%2, b: (i+5)}
      left = data.Table.fromArray rows
      right = data.Table.fromArray [{a:1}]
      pt2 = new data.PairTable left, right
      tset = data.PairTable.union pt1, pt2
      tset = tset.ensure()

      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, tset
      node.run()
      promise

    "has 2 rows": (pt) ->
      assert.equal pt.left().nrows(), 2

    "b totals": (pt) ->
      t = pt.left()
      rows = t.all()
      assert.equal rows[0].get('b'), 20
      assert.equal rows[1].get('b'), 25


suite.addBatch 
  extendedexec: extendedexec
  createdexec: createdexec
  "group by pairtable": aggexecTSet
  "group by tset": aggexecTSet
  "synchronous exec": syncExec 


suite.export module

