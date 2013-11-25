require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'



suite = vows.describe "stat.coffee"

#gg.util.Log.setDefaults {'':0}

runTest = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  pt = new data.PairTable table
  pt = pt.ensure()
  node.setInput 0, pt
  node.run()
  promise



suite.addBatch 
  "Bin2d":
    topic: ->
      rows = _.times 100, (i) ->
        { 
          x: Math.floor(Math.random()*2)
          y: Math.floor(Math.random()*2)
          z: 1
        };
      data.Table.fromArray rows

    "when binned": 
      topic: (table) ->
        node = new gg.stat.Bin2D
        runTest node, table

      "doesnt crash": (pt) ->
        pt.left().each (row) ->
          console.log [row.get('x'), row.get('y'), row.get('sum')]


  "Loess":
    topic: ->
      rows = _.times 10, (i) ->
        { x: i, y: i + Math.random()*4 };
      data.Table.fromArray rows

    "when smoothed": 
      topic: (table) ->
        node = new gg.stat.Loess
        runTest node, table

      "doesnt crash": (pt) ->
        pt.left().each (row) ->
          assert row?

  "Boxplot":
    topic: ->
      rows = _.times 30, (i) ->
        { x: i % 3, y: (i%3)*5 + Math.random()*5 };
      data.Table.fromArray rows

    "when smoothed": 
      topic: (table) ->
        node = new gg.stat.Boxplot
        runTest node, table

      "doesnt crash": (pt) ->
        pt.left().each (row) ->
          assert row?

  "CDF":
    topic: ->
      rows = _.times 30, (i) ->
        { x: i, y: i }
      data.Table.fromArray rows

    "when smoothed": 
      topic: (table) ->
        node = new gg.stat.CDF
        runTest node, table

      "doesnt crash": (pt) ->
        cum = 0
        pt.left().each (row) ->
          cum += row.get 'x'
          assert.equal row.get('y'), cum


  "Sort":
    topic: ->
      rows = _.times 30, (i) ->
        { x: 30-i, y: i }
      data.Table.fromArray rows

    "when smoothed": 
      topic: (table) ->
        node = new gg.stat.Sort
          col: 'x'
        runTest node, table

      "doesnt crash": (pt) ->
        prev = -1
        pt.left().each (row) ->
          assert.lt prev, row.get('x')




suite.export module

