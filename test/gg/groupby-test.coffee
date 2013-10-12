require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'



suite = vows.describe "groupby.coffee"

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
suite.addBatch
  "group by":
    topic: ->
      gb = new gg.xform.GroupBy 
        params:
          n: 5
          gbAttrs: ["x", "z"]
          aggFuncs: 
            "avg": "avg"
            'count': 'count'
            "sum": "sum"
      gb

    "when run": 
      topic: (node) ->
        promise = new events.EventEmitter
        node.on 'output', (id, idx, pt) ->
          promise.emit 'success', pt
        node.setInput 0, makeTable()
        node.run()
        promise

      "produces correct results": (res) ->
        res.getTable().each (row) ->
          avg = row.get('avg')
          count = row.get('count')
          sum = row.get('sum')
          if _.isFinite avg
            assert.equal avg, (sum/count)


  
 
suite.export module
