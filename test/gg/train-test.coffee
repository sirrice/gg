require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'

suite = vows.describe "train.coffee"
Schema = gg.data.Schema

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
      table = gg.data.Table.fromArray rows
      pt = new gg.data.PairTable table
      pt = pt.ensure ['facet-x', 'facet-y']
      gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')

    "full partition has diff ids": (pt) ->
      ps = pt.fullPartition()
      ids = _.map ps, (p) -> p.getMD().get(0, 'scales').id
      ids = _.uniq ids
      assert.equal ps.length, ids.length

    "after being trained":
      topic: (pt) ->
        node = new gg.scale.train.Data
        runTest node, pt

      "doesn't have _barrier": (pt) ->
        assert (not pt.tableSchema().has('_barrier'))

      "returns trained scales": (pt) ->
        md = pt.getMD()
        md.each (row) ->
          scales = row.get 'scales'
          #console.log scales.id
          #console.log scales.scale('x', gg.data.Schema.unknown).toString()

  "dataset":
    topic: ->
      rows = _.times 20, (i) ->
        {
          'facet-x': i % 2
          'facet-y': (i) % 3
          x: i * ((i % 2) + 1)
          y: i*10
        }
      table = gg.data.Table.fromArray rows
      pt = new gg.data.PairTable table
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
        md = pt.getMD()
        console.log md.schema.toString()
        md.each (row) ->
          scales = row.get 'scales'
          console.log scales.scale('x', gg.data.Schema.unknown).toString()

  "repositioned data":
    topic: ->
      rows = _.times 10, (i) ->
        {
          'facet-x': i % 2
          'facet-y': 0
          x: (i%3)*50
          y: (i%3)*50
        }
      table = gg.data.Table.fromArray rows
      pt = new gg.data.PairTable table
      pt = pt.ensure ['facet-x', 'facet-y']
      pt = gg.core.FormUtil.ensureScales pt, null, gg.util.Log.logger('test')
      pt = gg.scale.train.Data.train pt, new gg.util.Params({scalesTrain:'free'}), () ->
      t = gg.data.Transform.mapCols pt.getTable(), [
        ['x', ((x, idx) -> if idx % 2 == 0 then 200 else 0), Schema.numeric]
        ['y', ((y, idx) -> if idx % 2 == 0 then 200 else 0), Schema.numeric]
      ]
      pt = new gg.data.PairTable t, pt.getMD()
      pt

    "pixel train":
      topic: (pt) ->
        node = new gg.scale.train.Pixel
        pt.getMD().each (row) ->
          s = row.get('scales')
          s.scale('x', gg.data.Schema.unknown).range([0, 100])
          s.scale('y', gg.data.Schema.unknown).range([0, 100])
          s
        runTest node, pt

      "runs": (pt) ->
        pt.getTable().each (row) ->
          console.log row.raw()
        console.log pt.getMD().get(0, 'scales').toString()


suite.export module
