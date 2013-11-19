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
        table = data.Table.fromArray rows

        pt = new data.PairTable table
        pt = pt.ensure([])
        runOnTable node, pt

      "the md has scales": (pt) ->
        pt.left().each (row) ->
          assert.equal row.get('x2'), row.get('x')*2
          assert.equal row.get('z'), row.get('y')
  
  "Mapper with empty group":
    topic: ->
      new gg.xform.Mapper
        params:
          mapping:
            group: {}

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
          assert.deepEqual row.get('group'), {}
         
  "Mapper with explicit group":
    topic: ->
      new gg.xform.Mapper
        params:
          mapping:
            group:
              stroke: 'x'

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
 

  "Mapper with groupable cols":
    topic: ->
      new gg.xform.Mapper
        params:
          mapping:
            stroke: 'x'

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
          assert.equal row.get('stroke'), row.get('x')
  
suite.export module
