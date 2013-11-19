require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'

suite = vows.describe "facet.coffee"

gg.util.Log.setDefaults {'gg.scale.train': 0}

runTest = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise

makeTable = ->
  rows = [
    {'facet-x': 0, 'facet-y': 1, x:5, y:10 }
    {'facet-x': 1, 'facet-y': 1, x:5, y:10 }
    {'facet-x': 1, 'facet-y': 2, x:5, y:10 }
    {'facet-x': 1, 'facet-y': 3, x:5, y:10 }
    {'facet-x': 2, 'facet-y': 1, x:5, y:10 }
    {'facet-x': 2, 'facet-y': 2, x:5, y:10 }
    {'facet-x': 2, 'facet-y': 3, x:5, y:10 }
  ]
  table = data.Table.fromArray rows
  pt = new data.PairTable table
  pt = pt.ensure ['facet-x', 'facet-y']
  lc = 
    titleC: new gg.core.Bound
    facetC: new gg.core.Bound 0, 0, 500, 500
    baseC: new gg.core.Bound 0, 0, 500, 500
  md = pt.right()
  md = md.setColVal 'lc', lc
  md = md.setColVal 'svg', 0
  pt = new data.PairTable pt.left(), md
  gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')

suite.addBatch
  "Grid Layout":
    topic: ->
      makeTable()

    "after running layout":
      topic: (pt) ->
        node = new gg.facet.grid.Layout
        runTest node, pt

      "doesn't have _barrier": (pt) ->
        assert (not pt.leftSchema().has('_barrier'))

      "has panes": (pt) ->
        md = pt.right()
        md.each (row) ->
          assert row?

suite.export module
