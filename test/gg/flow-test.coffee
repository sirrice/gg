require "../env"
vows = require "vows"
assert = require "assert"
events = require "events"

Schema = data.Schema

makeTable = (nrows=100) ->
  rows = _.times nrows, (i) -> 
    a:1+i
    b:i%10
    c: i%2
    d: i%10
    id:i
  table = data.Table.fromArray  rows
  table



suite = vows.describe "gg.wf.Flow"
#gg.util.Log.setDefaults '': 0

suite.addBatch {
  "Single Node Flow":
    topic: ->
      flow = new gg.wf.Flow
      flow.exec (pairtable, params, cb) -> 
        table = pairtable.left()
        f = (b) -> b* 100
        table = table.project {alias: 'b',  f: f}
        ret = new data.PairTable table, pairtable.right()
        cb null,ret
      flow

    "can print": (flow) ->
      f = ()->flow.toString()
      assert.doesNotThrow f, Error

    "is instantiated properly": (flow) ->
      root = flow.instantiate()

    "when run": 
      topic: (flow) ->
        promise = new events.EventEmitter
        flow.prepend gg.core.Data.spec2Node
          type: "table"
          val: makeTable 10
        flow.on "output", (id, outidx, pt) ->
          promise.emit "success", pt
        flow.run()
        promise

      "is correct": (pt) ->
        assert.isNotNull pt
        pt.left().each (row) ->
          assert.equal row.get('b'), row.get('d')*100


  "Two node flow":
      topic: ->
          flow = new gg.wf.Flow
          flow.exec
            name: "node1"
            params: 
              compute: (pt, params, cb) -> 
                t = pt.left()
                t = t.setColVal 'a', -1
                cb null, new data.PairTable(t, pt.right())
          flow.exec
            name: "node2"
            params: 
              compute: (pt, params, cb) -> 
                t = pt.left()
                t = t.setColVal 'b', 100
                cb null, new data.PairTable(t, pt.right())
          flow

      "can print": (flow) ->
          correct = "node1@client\t->\tnode2(1)\nnode2@client\t->\tSINK"
          assert.equal correct, flow.toString()

      "when run": 
        topic: (flow) ->
          promise = new events.EventEmitter
          flow.prepend gg.core.Data.spec2Node
            type: "table"
            val: makeTable 10
          flow.on "output", (id, outidx, pt) ->
            promise.emit "success", pt
          flow.run()
          promise

        "checks out": (pt) ->
          assert.isNotNull pt
          pt.left().each (row) ->
              assert.equal row.get('a'), -1
              assert.equal row.get('b'), 100


  "10 node flow":
    topic: ->
      flow = new gg.wf.Flow
      _.time 10, (i) ->
        flow.exec 
          name: "node#{i}"
          params:
            compute: (pt, params, cb) -> 
              t = pt.left().setColVal "o#{i}", i
              ret = new data.PairTable t, pt.right()
              cb null, ret
      flow

      "when run": 
        topic: (flow) ->
          promise = new events.EventEmitter
          flow.prepend gg.core.Data.spec2Node
            type: "table"
            val: makeTable 10
          flow.on "output", (id, outidx, pt) ->
            promise.emit "success", pt
          flow.run()
          promise


        "is correct": (pt) ->
          assert.isNotNull pt
          pt.left().each (row) ->
            _.each _.range(10), (i) ->
                assert.equal row.get("o#{i}"), i

}




suite.export module
