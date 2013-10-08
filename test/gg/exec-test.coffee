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
      rows = _.times 10, (i) -> {a: i, b: i}
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


suite.addBatch 
  createdexec: createdexec
  extendedexec: extendedexec


suite.export module

