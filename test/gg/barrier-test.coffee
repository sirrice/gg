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
      table1 = data.Table.fromArray(
        _.times(10, (i) -> {a: i, b: 2})
      )
      table2 = data.Table.fromArray(
        _.times(10, (i) -> {a: i, b: 5})
      )
      pt1 = new data.PairTable table1
      pt2 = new data.PairTable table2
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

    "'c' = 'a' x 'b'": (tsets) ->
      for tset in tsets
        tset.left().each (row) ->
          assert.equal row.get('c'), (row.get('a')*row.get('b'))

    "_barrier doesn't exist": (tsets) ->
      for tset in tsets
        assert.false tset.left().has('_barrier')



barrier = 
  topic: ->
    gg.wf.Barrier.create (tset, params, cb) ->
      t = tset.left()
      t = t.project [{
        alias: 'c',
        f: (a, b) -> a*b
        cols: ['a', 'b']
        type: data.Schema.numeric
      }], yes
      tset = new data.PairTable t, tset.right()
      cb null, tset
_.extend barrier, check


suite.addBatch 
  barrier: barrier


suite.export module

