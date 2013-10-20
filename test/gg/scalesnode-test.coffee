require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'



suite = vows.describe "xform.scale.coffee"

makeTable = ->
  scale1 = new gg.scale.Linear 
    aes: "x"
  scale1.domain [0, 100]
  scale1.range [0, 100]
  scale2 = new gg.scale.Linear
    aes: "z"
  scale2.domain [0, 200]
  scale2.range [0, 200]
  f = new gg.scale.Factory
  set = new gg.scale.Set f
  set.scale scale1
  set.scale scale2

  rows = _.times 1000, (i) -> 
    if i < 10
      {x: NaN, y: NaN }
    else
      {
        x: i%100
        z: Math.floor(Math.random()*200)
        y: (i+1)%2}
  table = gg.data.Table.fromArray rows
  md = gg.data.Table.fromArray [{scales: set}]
  new gg.data.PairTable table, md


  #gg.util.Log.setDefaults {'': 0}

runOnTable = (node, table) ->
  promise = new events.EventEmitter
  node.on 'output', (id, idx, pt) ->
    promise.emit 'success', pt
  node.setInput 0, table
  node.run()
  promise




suite.addBatch
  "ScalesSchema":
    topic: ->
      new gg.xform.ScalesSchema

    "when run on empty md":
      topic: (node) ->
        rows = _.times 10, (i) ->
          a: i
          x: i
        table = gg.data.Table.fromArray rows
        md = gg.data.Table.fromArray [
          {
            scalesconfig: gg.scale.Config.fromSpec({
              x: 
                type: 'linear'
                range: [0, 100]
            })
          }]
        pt = new gg.data.PairTable table, md
        pt = pt.ensure([])
        runOnTable node, pt

      "the md has scales": (pt) ->
        md = pt.getMD()
        ss = md.get 0, 'scales'
  
  "ScalesApply":
    topic: ->
      new gg.xform.ScalesApply

    "when run":
      topic: (node) ->
        rows = _.times 10, (i) ->
          a: i
          y: i
          x: i
        table = gg.data.Table.fromArray rows
        config = gg.scale.Config.fromSpec
          x: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 100]
          y: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 1000]

        md = gg.data.Table.fromArray [
          { scalesconfig: config }]
        pt = new gg.data.PairTable table, md
        pt = pt.ensure([])
        pt = gg.core.FormUtil.ensureScales pt
        runOnTable node, pt

      "is correct": (pt) ->
        pt.getTable().each (row) ->
          a = row.get 'a'
          x = row.get 'x'
          y = row.get 'y'
          assert.lt Math.abs(a*10-x), 0.001
          assert.lt Math.abs(a*100-y), 0.001

  "ScalesInvert":
    topic: ->
      new gg.xform.ScalesInvert

    "when run":
      topic: (node) ->
        rows = _.times 10, (i) ->
          a: i
          y: i*100
          x: i*10
        table = gg.data.Table.fromArray rows
        config = gg.scale.Config.fromSpec
          x: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 100]
          y: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 1000]

        md = gg.data.Table.fromArray [
          { scalesconfig: config }]
        pt = new gg.data.PairTable table, md
        pt = pt.ensure([])
        pt = gg.core.FormUtil.ensureScales pt
        runOnTable node, pt

      "results are correct": (pt) ->
        pt.getTable().each (row) ->
          a = row.get 'a'
          x = row.get 'x'
          y = row.get 'y'
          assert.lt Math.abs(a-x), 0.001
          assert.lt Math.abs(a-y), 0.001


  "ScalesFilter":
    topic: ->
      new gg.xform.ScalesFilter

    "when run":
      topic: (node) ->
        rows = _.times 100, (i) ->
          a: i
          y: i*100
          x: i*10
          z: i
        table = gg.data.Table.fromArray rows
        config = gg.scale.Config.fromSpec
          x: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 100]
          y: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 1000]

        md = gg.data.Table.fromArray [
          { scalesconfig: config }]
        pt = new gg.data.PairTable table, md
        pt = pt.ensure([])
        pt = gg.core.FormUtil.ensureScales pt
        runOnTable node, pt

      "results are correct": (pt) ->
        pt.getTable().each (row) ->
          a = row.get 'a'
          x = row.get 'x'
          y = row.get 'y'
          assert.lt Math.abs(a-x), 0.001
          assert.lt Math.abs(a-y), 0.001
          assert (a < 11)
          assert (y < 11)



  "ScalesValidate":
    topic: ->
      new gg.xform.ScalesValidate

    "when run":
      topic: (node) ->
        rows = _.times 100, (i) ->
          y = if i < 10 then NaN else i
          {
            a: i
            x: i*10
            y: y
          }
        table = gg.data.Table.fromArray rows
        config = gg.scale.Config.fromSpec
          x: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 100]
          y: 
            type: 'linear'
            domain: [0, 10]
            range: [0, 1000]

        md = gg.data.Table.fromArray [
          { scalesconfig: config }]
        pt = new gg.data.PairTable table, md
        pt = pt.ensure([])
        pt = gg.core.FormUtil.ensureScales pt
        runOnTable node, pt

      "results are correct": (pt) ->
        pt.getTable().each (row) ->
          a = row.get 'a'
          x = row.get 'x'
          y = row.get 'y'

 
suite.export module
