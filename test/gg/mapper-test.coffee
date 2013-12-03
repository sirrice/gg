require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'
#gg.util.Log.setDefaults {'gg.xform.m': 0}



suite = vows.describe "mapper.coffee"


runOnTable = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise

suite.addBatch


  "Mapper with explicit group":
    topic: ->
      new gg.xform.Mapper
        aes:
          group:
            stroke: 'x'
          a: "{x+10}"
          b: "y"

    "when run on empty md":
      topic: (node) ->
        rows = _.times 10, (i) ->
          x: i
          y: i
        table = data.Table.fromArray rows

        pt = new data.PairTable table
        pt = pt.ensure([])
        runOnTable node, pt

      "the group is correct": (pt) ->
        pt.left().each (row) ->
          assert.equal row.get('group').stroke, row.get('x')
          assert.equal row.get('a'), row.get('x')+10
          assert.equal row.get('b'), row.get('y')
 
 
suite.export module
