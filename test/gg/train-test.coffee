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
      gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')

    "full partition has diff ids": (pt) ->
      ps = pt.fullPartition()
      ids = _.map ps, (p) -> p.right().any('scales').id
      ids = _.uniq ids
      assert.equal ps.length, ids.length

    "after being trained":
      topic: (pt) ->
        node = new gg.scale.train.Data
        runTest node, pt

      "doesn't have _barrier": (pt) ->
        assert (not pt.leftSchema().has('_barrier'))

      "returns trained scales": (pt) ->
        md = pt.right()
        md.each (row) ->
          scales = row.get 'scales'

  "dataset":
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
      pt = gg.scale.train.Data.train pt, new gg.util.Params({scalesTrain:'free'}), () ->

    "then trained on master":
      topic: (pt) ->
        node = new gg.scale.train.Master
          params: 
            scalesTrain: 'free'
        runTest node, pt

      "doesnt crash": (pt) ->
        md = pt.right()
        md.each (row) ->
          scales = row.get 'scales'

  "repositioned data":
    topic: ->
      rows = _.times 10, (i) ->
        {
          'facet-x': i % 2
          'facet-y': 0
          x: (i%3)*50
          y: (i%3)*50
        }
      table = data.Table.fromArray rows
      pt = new data.PairTable table
      pt = pt.ensure ['facet-x', 'facet-y']
      pt = gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')
      pt = gg.scale.train.Data.train pt, new gg.util.Params({scalesTrain:'free'}), () ->
      t =  pt.left().mapCols [
        { alias: 'x', f:(x, idx) -> if idx % 2 == 0 then 200 else 0 }
        { alias: 'y', f:(y, idx) -> if idx % 2 == 0 then 200 else 0 }
      ]
      pt = new data.PairTable t, pt.right()
      pt

    "pixel train":
      topic: (pt) ->
        node = new gg.scale.train.Pixel
        pt.right().each (row) ->
          s = row.get('scales')
          s.scale('x', data.Schema.unknown).range([0, 100])
          s.scale('y', data.Schema.unknown).range([0, 100])
          s
        runTest node, pt

      "runs": (pt) ->
        pt.left().each (row) ->
          console.log row.raw()
        console.log pt.right().any('scales').toString()


suite.export module
