require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'

suite = vows.describe "train.coffee"
Schema = data.Schema

#gg.util.Log.setDefaults {'gg.scale.train': 0}

runTest = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise

suite.addBatch 
  "faceted dataset":
    topic: ->
      rows = _.times 20, (i) ->
        {
          'facet-x': i % 2
          'facet-y': (i) % 3
          x: i * ((i % 2) + 1)
          y: i*10
        }
      table = data.Table.fromArray rows
      pt = new data.PairTable table
      pt = pt.ensure ['facet-x', 'facet-y']
      pt = gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')


    "after being trained":
      topic: (pt) ->
        console.log "hi"
        node = new gg.scale.train.Data
        console.log "training"
        runTest node, pt

      "doesn't have _barrier": (pt) ->
        assert (not pt.leftSchema().has('_barrier'))

      "returns trained scales": (pt) ->
        md = pt.right()
        md.each (row) ->
          scales = row.get 'scales'

suite.export module
