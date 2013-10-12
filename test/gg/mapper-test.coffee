require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'


suite = vows.describe "mapper.coffee"

#gg.util.Log.setDefaults {'': 0}

runOnTable = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise

suite.addBatch
  "Mapper":
    topic: ->
      new gg.xform.Mapper
        params:
          mapping:
            x2: "{x*2}"
            z: 'y'

    "when run on empty md":
      topic: (node) ->
        rows = _.times 10, (i) ->
          x: i
          y: i
        table = gg.data.Table.fromArray rows

        pt = new gg.data.PairTable table
        pt = pt.ensure([])
        runOnTable node, pt

      "the md has scales": (pt) ->
        pt.getTable().each (row) ->
          assert.equal row.get('x2'), row.get('x')*2
          assert.equal row.get('z'), row.get('y')
  
 
suite.export module
