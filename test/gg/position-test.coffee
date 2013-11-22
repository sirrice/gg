require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'



suite = vows.describe "position.coffee"

suite.addBatch {
  "dotplot": 
    topic: ->
      rows = _.times 10, (i) ->
        { 
          x: i + Math.random() * 1
        }
      p1 = data.Table.fromArray rows

      config = gg.scale.Config.fromSpec { x: 'linear', y: 'linear' }
      set = config.scales(['x', 'y'])
      set.get('x', data.Schema.unknown).range([0, 10])
      set.get('y', data.Schema.unknown).range([0, 10])
      p2 = data.Table.fromArray [{scales: set}]
      new data.PairTable p1, p2

    "when run": 
      topic: (pt) ->
        promise = new events.EventEmitter
        pos = new gg.pos.DotPlot
          params:
            r: 3
        pos.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        pos.setInput 0, pt
        pos.run()
        promise

      # XXX: relies internal implementation to add a '_base' column to table
      "is correct": (pt) ->
        pt.left().each (row) ->
          assert row?


  "dodge":
    topic: ->
      rows = _.times 10, (i) ->
        j = Math.floor(i/5)*3 + 1
        { 
          group: i%2
          x: j*10
          x0: j*10-4
          x1: j*10+4, 
          '_base': [j*10-4, j*10+4] 
        }
      data.Table.fromArray rows


    "when dodged": 
      topic: (table) ->
        promise = new events.EventEmitter
        pos = new gg.pos.Dodge
        pos.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        pt = new data.PairTable table
        pt = pt.ensure()
        pos.setInput 0, pt
        pos.run()
        promise

      # XXX: relies internal implementation to add a '_base' column to table
      "is correct": (pt) ->
        pt.left().each (row) ->
          base = row.get '_base'
          x0 = row.get 'x0'
          x1 = row.get 'x1'
          assert.lt x0, x1
          assert (x0 >= base[0] and x1 <= base[1])
          assert (x1 >= base[0] and x1 <= base[1])


  "shift":
    topic: ->
      rows = _.times 10, (i) ->
        { x: i, y: i, z: i }
      data.Table.fromArray rows


    "when shifted": 
      topic: (table) ->
        promise = new events.EventEmitter
        pos = new gg.pos.Shift
          x: 10
          y: 10

        pos.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        pt = new data.PairTable table
        pt = pt.ensure()
        pos.setInput 0, pt
        pos.run()
        promise

      "is correct": (pt) ->
        pt.left().each (row) ->
          assert.equal row.get('y'), row.get('z')+10
          assert.equal row.get('x'), row.get('z')+10

  "stack":
    topic: ->
      rows = [
        {group: 0, z:0,  x: 0,  y: 0, y1: 0 },
        {group: 0, z:10,  x: 10, y: 10,y1: 10},
        {group: 0, z:20,  x: 20, y: 20,y1: 20}
        {group: 1, z:5,  x: 0,  y: 5, y1: 5 },
        {group: 1, z:15,  x: 10, y: 15,y1: 15},
        {group: 1, z:25,  x: 20, y: 25,y1: 25}
      ]

      data.Table.fromArray rows

    "when stacked": 
      topic: (table) ->
        promise = new events.EventEmitter
        pos = new gg.pos.Stack
        pos.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        pt = new data.PairTable table
        pt = pt.ensure()
        pos.setInput 0, pt
        pos.run()
        promise

      "result": (pt) ->
        pt.left().each (row) ->
          if row.get('group') == 0
            assert.equal row.get('z'), row.get('y')
          else
            assert.lte row.get('z'), row.get('y')

  "bin2d":
    topic: ->
      new gg.pos.Bin2D

    "when run": 
      topic: (node) ->
        promise = new events.EventEmitter
        node.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        node.setInput 0, makeTable()
        node.run()
        promise

      "produces correct results": (res) ->
        res.left().each (row) ->
          avg = row.get('avg')
          count = row.get('count')
          sum = row.get('sum')
          if _.isFinite avg
            assert.equal avg, (sum/count)


 
}


suite.export module
