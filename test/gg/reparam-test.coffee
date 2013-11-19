require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'


suite = vows.describe "reparam.coffee"

#gg.util.Log.setDefaults {'': 0}

makeTable = ->
  rows = _.times 10, (i) ->
    x: i
    y: i
    q1: i
    median: i
    q3: i
    lower: i
    upper: i
    outlier: null
    min: i
    max: i


  table = data.Table.fromArray rows

  config = gg.scale.Config.fromSpec
    x: 
      type: 'linear'
      domain: [0, 10]
      range: [0, 100]
    y: 
      type: 'linear'
      domain: [0, 10]
      range: [0, 1000]

  md = data.Table.fromArray [ {scalesconfig: config} ]
  pt = new data.PairTable table, md
  pt = pt.ensure([])
  pt = gg.core.FormUtil.ensureScales pt, {}, gg.util.Log.logger("")


runOnTable = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise

suite.addBatch
  "Rect Reparam":
    topic: ->
      new gg.geom.reparam.Rect

    "when run on data":
      topic: (node) ->
        pt = makeTable()
        runOnTable node, pt

      "the md has scales": (pt) ->
        table = pt.left()
        assert table.has('x0')
        assert table.has('x1')
        assert table.has('y0')
        assert table.has('y1')
  
  "Boxplot Reparam":
    topic: ->
      new gg.geom.reparam.Boxplot

    "when run on data":
      topic: (node) ->
        pt = makeTable()
        runOnTable node, pt

      "the md has scales": (pt) ->
        pt.left().each (row) ->
  
  "Point Reparam":
    topic: ->
      new gg.geom.reparam.Point

    "when run on data":
      topic: (node) ->
        pt = makeTable()
        runOnTable node, pt

      "table as reparamed cols": (pt) ->
        table = pt.left()
        assert table.has('x0')
        assert table.has('x1')
        assert table.has('y0')
        assert table.has('y1')
        assert table.has('r')
        table.each (row) ->
          x = row.get 'x'
          x0 = row.get 'x0'
          r = row.get 'r'
          assert.equal (x-r), x0

  "Line Reparam":
    topic: ->
      new gg.geom.reparam.Line

    "when run on data":
      topic: (node) ->
        pt = makeTable()
        runOnTable node, pt

      "table as reparamed cols": (pt) ->
        table = pt.left()
        assert table.has('y0'), 'table should have y0'
        assert table.has('y1'), 'table should have y1'
        table.each (row) ->
          y = row.get 'y'
          y1 = row.get 'y1'
          r = row.get 'r'
          assert.equal y, y1

 
suite.export module
