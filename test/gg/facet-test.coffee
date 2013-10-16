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
  console.log rows
  table = gg.data.Table.fromArray rows
  pt = new gg.data.PairTable table
  pt = pt.ensure ['facet-x', 'facet-y']
  lc = 
    titleC: new gg.core.Bound
    facetC: new gg.core.Bound 0, 0, 500, 500
    baseC: new gg.core.Bound 0, 0, 500, 500
  md = gg.data.Transform.transform pt.getMD(),
    lc: () -> lc
    svg: () -> 0
  pt = new gg.data.PairTable pt.getTable(), md
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
        assert (not pt.tableSchema().has('_barrier'))

      "has panes": (pt) ->
        md = pt.getMD()
        md.each (row) ->
          console.log [row.get('facet-x'), row.get('facet-y')]
          console.log row.get('paneC').c
          console.log row.get('svg')

suite.export module
