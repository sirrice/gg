require "../env"
events = require "events"
vows = require "vows"
assert = require "assert"



suite = vows.describe "exec.js"
Schema = gg.data.Schema
Transform = gg.data.Transform
Table = gg.data.Table

check = 
  "when executed": 
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 10, (i) -> {a: i%2, b: i}
      table = gg.data.Table.fromArray rows
      pt = new gg.data.PairTable table
      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, pt
      node.run()
      promise

    "has 10 results": (pt) ->
      assert.equal pt.getTable().nrows(), 10

    "has correct 'attr1'": (pt) ->
      pt.getTable().each (row) ->
        v = row.get 'attr1'
        assert.lte v, 0, "attr1 #{v} should be <= 0"



createdexec = 
  topic: ->
    gg.wf.Exec.create null, (pairtable, params, cb) ->
      table = gg.data.Transform.map pairtable.getTable(),
        attr1: (row) -> row.get('a') * -1
      pairtable = new gg.data.PairTable table, pairtable.getMD()
      cb null, pairtable
_.extend createdexec, check

extendedexec = 
  topic: ->
    klass = class ExecKlass extends gg.wf.Exec
      compute: (pairtable, params, cb) ->
        table = pairtable.getTable()
        table = gg.data.Transform.map table, 
          attr1: (row) -> row.get('a') * -1
        pairtable = new gg.data.PairTable table, pairtable.getMD()
        cb null, pairtable
    new klass
_.extend extendedexec, check

createAggExec = ->
  gg.wf.Exec.create { key: 'a' }, (pairtable, params, cb) ->
    t = pairtable.getTable()
    bcol = t.getCol 'b'
    total = _.sum bcol
    schema = t.schema.project 'a'
    schema.addColumn 'b', gg.data.Schema.numeric
    row = { a:t.get(0,'a'), b: total}

    t = t.constructor.fromArray [row], schema
    pairtable = new gg.data.PairTable t, pairtable.getMD()
    cb null, pairtable



aggexecPairTable = 
  topic: createAggExec
  "when executed on pairtable": 
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 10, (i) -> {a: i%2, b: i}
      table = gg.data.Table.fromArray rows
      pt = new gg.data.PairTable table
      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, pt
      node.run()
      promise

    "has 2 rows": (pt) ->
      assert.equal pt.getTable().nrows(), 2

    "b totals": (pt) ->
      t = pt.getTable()
      assert.equal t.get(0, 'b'), 20
      assert.equal t.get(1, 'b'), 25

aggexecTSet = 
  topic: createAggExec
  "when executed on tableset": 
    topic: (node) ->
      promise = new events.EventEmitter
      rows = _.times 5, (i) -> {a: i%2, b: i}
      table = gg.data.Table.fromArray rows
      pt1 = new gg.data.PairTable table
      rows = _.times 5, (i) -> {a: (i+5)%2, b: (i+5)}
      table = gg.data.Table.fromArray rows
      pt2 = new gg.data.PairTable table
      tset = new gg.data.TableSet [pt1, pt2]

      node.on 'output', (id, idx, pt) ->
        promise.emit "success", pt
      node.setInput 0, tset
      node.run()
      promise

    "has 2 rows": (pt) ->
      assert.equal pt.getTable().nrows(), 2

    "b totals": (pt) ->
      t = pt.getTable()
      assert.equal t.get(0, 'b'), 20
      assert.equal t.get(1, 'b'), 25


suite.addBatch 
  extendedexec: extendedexec
  createdexec: createdexec
  "group by pairtable": aggexecTSet
  "group by tset": aggexecTSet


suite.export module

