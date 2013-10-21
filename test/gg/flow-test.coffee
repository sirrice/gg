require "../env"
vows = require "vows"
assert = require "assert"
events = require "events"

Schema = gg.data.Schema

makeTable = (nrows=100) ->
  rows = _.times nrows, (i) -> 
    a:1+i
    b:i%10
    c: i%2
    d: i%10
    id:i
  table = gg.data.Table.fromArray  rows
  table



suite = vows.describe "gg.wf.Flow"
#gg.util.Log.setDefaults '': 0

suite.addBatch {
  "Single Node Flow":
      topic: ->
          flow = new gg.wf.Flow
          flow.exec (pairtable, params, cb) -> 
            console.log "hi"
            table = pairtable.getTable()
            table = gg.data.Transform.transform table, [
              ['b', ((row) -> row.get('b') * 100), Schema.numeric]
            ]
            ret = new gg.data.PairTable table, pairtable.getMD()
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
          flow.on "output", (id, pt) ->
            promise.emit "success", pt
          flow.run()
          promise

        "is correct": (pt) ->
          assert.isNotNull pt
          pt.getTable().each (row) ->
            assert.equal row.get('b'), row.get('d')*100


  "Two node flow":
      topic: ->
          flow = new gg.wf.Flow
          flow.exec
            name: "node1"
            params: 
              compute: (pt, params, cb) -> 
                t = pt.getTable()
                t = gg.data.Transform.transform t,[
                  ['a', ((row) -> -1), Schema.numeric]
                ]
                cb null, new gg.data.PairTable(t, pt.getMD())
          flow.exec
            name: "node2"
            params: 
              compute: (pt, params, cb) -> 
                t = pt.getTable()
                t = gg.data.Transform.transform t,[
                  ['b', ((row) -> 100), Schema.numeric]
                ]
                cb null, new gg.data.PairTable(t, pt.getMD())
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
          flow.on "output", (id, pt) ->
            promise.emit "success", pt
          flow.run()
          promise

        "checks out": (pt) ->
          assert.isNotNull pt
          pt.getTable().each (row) ->
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
              map = [["o#{i}", ((row) -> i), null]]
              t = gg.data.Transform.transform pt.getTable(), map
              ret = new gg.data.PairTable t, pt.getMD()
              cb null, ret
      flow

      "when run": 
        topic: (flow) ->
          promise = new events.EventEmitter
          flow.prepend gg.core.Data.spec2Node
            type: "table"
            val: makeTable 10
          flow.on "output", (id, pt) ->
            promise.emit "success", pt
          flow.run()
          promise


        "is correct": (pt) ->
          assert.isNotNull pt
          pt.getTable().each (row) ->
            _.each _.range(10), (i) ->
                assert.equal row.get("o#{i}"), i
}

foo =                
  "Single partition-join flow using spec":
      topic: ->
          flow = new gg.wf.Flow
          flow.partition {name: "split", f: (row) -> row.get('b')}
          flow.join {name: "join"}
          flow

      "creates 10 partitions": (flow) ->
          flow.on "output", (id, pt) ->
            assert.equal pt.getTable().nrows(), 10
          flow.run makeTable(10)

  "Single partition-join flow no spec object":
      topic: ->
          flow = new gg.wf.Flow
          flow.partition (row) -> row.get('b')
          flow.join()
          flow

      "creates 10 partitions": (flow) ->
          flow.on "output", (id, table) ->
            assert.equal table.getTable().nrows(), 10
          flow.run makeTable(10)

  "Nested partiiton-join":
      topic: ->
          flow = new gg.wf.Flow
          flow.partition {name: "split1", f: (row) -> row.get('b')}
          flow.partition {name: "split2", f: (row) -> row.get('c')}
          flow.join {name: "join2"}
          flow.join {name: "join1"}
          flow

      "creates 2 sets of groups (10 and 2 groups in each set)": (flow) ->
          flow.on "output", (id, table) ->
              col1 = _.times table.nrows(), (idx) -> table.get(idx, "split1")
              col1 = _.uniq col1
              col2 = _.times table.nrows(), (idx) -> table.get(idx, "split2")
              col2 = _.uniq col2

              assert.equal col1.length, 10
              assert.equal col2.length, 2
          flow.run makeTable(100)

  "partition-compute-join":
      topic: ->
          flow = new gg.wf.Flow
          flow.partition {name: "split1", key: "groupKey", f: (row) -> row.get('b')}
          flow.exec (table) ->
              col = table.getCol 'a'
              total = _.foldr col, ((a,b)->a+b), 0
              n = col.length
              gg.data.RowTable.fromArray  [{sum: total, n: n, avg: total / n}]
          flow.join {name: "join"}

      "runs": (flow) ->
          truth = [460, 470, 480, 490, 500, 510, 520, 530, 540, 550]
          groupKeys = _.range 10
          flow.on "output", (id, table) ->
            table.each (row) ->
                assert.include truth, row.get('sum')
                assert.equal row.get('n'), 10
                assert.include groupKeys, row.get('groupKey')
          flow.run makeTable(100)

  "multicast-[exec,exec]":
      topic: ->
          flow = new gg.wf.Flow

  "MultiBarrier flow":
    topic: ->
      flow = new gg.wf.Flow
      multicast = new gg.wf.Multicast {name: "multicast"}
      newb = (name) -> new gg.wf.Barrier {name: name}
      newe = (name) -> new gg.wf.Exec {name: name}

      b1 = newb "barrier1"
      b2 = newb "barrier2"
      b3 = newb "barrier3"
      b4 = newb "barrier4"
      b5 = newb "barrier5"
      x = newe "x"
      y = newe "y"
      a = newe "a"
      c = newe "c"
      d = newe "d"
      e = newe "e"

      flow.connect multicast, x
      flow.connect multicast, y
      flow.connect x, b1
      flow.connect y, b1
      flow.connect b1, b2
      flow.connect b1, b2
      flow.connect b2, a
      flow.connect b2, c
      flow.connect a, b3
      flow.connect c, b3
      flow.connect b3, b4
      flow.connect b3, b4
      flow.connect b4, d
      flow.connect b4, e
      flow.connectBridge multicast, x
      flow.connectBridge multicast, y
      flow.connectBridge x, a
      flow.connectBridge y, c
      flow.connectBridge a, d
      flow.connectBridge c, e

      flow

    "can be instantiated": (flow) ->
      #foo = flow.instantiate()







suite.export module
