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
      table1 = gg.data.Table.fromArray(
        _.times(10, (i) -> {a: i, b: 2})
      )
      table2 = gg.data.Table.fromArray(
        _.times(10, (i) -> {a: i, b: 5})
      )
      pt1 = new gg.data.PairTable table1
      pt2 = new gg.data.PairTable table2
      node.setInput 0, pt1
      node.setInput 1, pt2
      results = []
      f = (id, idx, tset) ->
        results.push tset
        if results.length >= 2
          promise.emit 'success', results
      node.on 'output', f

      node.run()
      promise

    "'c' = 'a' * 'b'": (tsets) ->
      for tset in tsets
        tset.getTable().each (row) ->
          assert.equal row.get('c'), (row.get('a')*row.get('b'))

    "_barrier doesn't exist": (tsets) ->
      for tset in tsets
        assert.false tset.getTable().has('_barrier')



barrier = 
  topic: ->
    gg.wf.Barrier.create (tset, params, cb) ->
      t = tset.getTable()
      t = gg.data.Transform.transform t, { 
        c: (row) -> row.get('a')*row.get('b')
      }
      tset = new gg.data.PairTable t, tset.getMD()
      cb null, tset
_.extend barrier, check


suite.addBatch 
  barrier: barrier


suite.export module

