require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'

suite = vows.describe "xform.coffee"


makeTable = (nrows=100) ->
  rows = _.times nrows, (i) -> {a:1+i, b:i%10, id:i}
  table = gg.data.Table.fromArray rows
  pt = new gg.data.PairTable table
  pt.ensure []


genCheckRows = (check) ->
  (node) ->
    promise = new events.EventEmitter()
    node.on 'output', (id, idx, pt) ->
      pt.getTable().each check
      promise.emit 'success', pt

    d = makeTable 10
    node.setInput 0, d
    node.run()
    promise

genCheckTable = (check) ->
  (node) ->
    promise = new events.EventEmitter()
    node.on '0', (id, idx, pt) ->
      check pt
      promise.emit 'success', pt

    node.setInput 0, makeTable(10)
    node.run()
    promise




suite.addBatch
  "Exec" :
    topic: new gg.wf.Exec
      params:
        f: (pt) ->
          t = pt.getTable()
          t = gg.data.Transform.transform t, 
            a: (row) -> -row.get('a')
          new gg.data.PairTable t, pt.getMD()

    "runs compute correctly": genCheckTable  (pt) ->
      assert.equal 10, pt.getTable().nrows()

    "outputs properly": genCheckRows (row) ->
      assert.lt row.get('a'), 0, "#{row.get 'a'} !< 0"

    "when cloned":
      topic: (node) -> node.clone()

      "has a name": (node) -> assert.isNotNull node.name

      "outputs properly": genCheckRows (row) -> 
        assert.lt row.get('a'), 0


  "TableSource" :
    topic: ->
      rows = _.times 100, (i) -> {a:1+i, b:i%10, id:i}
      new gg.wf.TableSource 
        params: 
          table: gg.data.Table.fromArray rows

    "outputs a single table": 
      topic: (node) ->
        promise = new events.EventEmitter
        node.on 'output', (id, idx, pt) ->
          promise.emit "success", pt
        node.setInput 0, new gg.data.PairTable()
        node.run()
        promise

      "correct": (pt) ->
        table = pt.getTable()
        assert.equal table.nrows(), 100




suite.export module
