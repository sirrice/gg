require "../env"
vows = require "vows"
assert = require "assert"


makeTable = (nrows=100) ->
  rows = _.map _.range(nrows), (i) -> {a:1+i, b:i%10, id:i}
  table = gg.data.RowTable.fromArray (rows)
  new gg.wf.Data table


genCheckRows = (check) ->

  (node) ->
    node.on '0', (id, idx, datas) ->
      for data in datas
        table = data.table
        table.each check

    d = makeTable 10
    node.setInput 0, [d]
    node.run()

genCheckTable = (check) ->

  (node) ->
    node.on '0', (id, idx, datas) ->
      for data in datas
        table = data.table
        check table

    d = makeTable 10
    node.setInput 0, [d]
    node.run()



suite = vows.describe "xform.coffee"

suite.addBatch
  "single node xform" :
    topic: new gg.wf.Exec
      params:
        f: (data) ->
          table = data.table.transform 'a', (v) -> -v.get('a')
          new gg.wf.Data table

    "runs compute correctly": genCheckTable  (table) ->
      assert.equal 10, table.nrows()

    "outputs properly": genCheckRows (row) ->
      assert.lt row.get('a'), 0, "#{row.get 'a'} !< 0"

    "when cloned":
      topic: (node) -> node.clone()

      "has a name": (node) -> assert.isNotNull node.name

      "outputs properly": genCheckRows (row) -> assert.lt row.get('a'), 0

  "table source node" :
    topic: new gg.wf.TableSource 
      params: 
        table: makeTable()

    "outputs a single table": (node) ->
      node.on '0', (id, idx, datas) ->
        for data in datas
          assert.equal 100, table.nrows()
      node.run()

  "partition node" :
    topic: new gg.wf.Partition
      params:
        f: (row) -> row.get('a')

    "has 10 groups": (node) ->
      node.setInput 0, makeTable(10)
      node.on '0', (id, idx, datas) ->
        assert.equal 10, _size(datas)

    "whew cloned":
      topic: (node) -> node.clone(yes)

      "still has 10 groups": (node) ->
        node.setInput 0, makeTable(10)
        node.on '0', (id, idx, datas) ->
          assert.equal 10, _size(datas)

  "split node":
    topic: new gg.wf.Split {f: (table) -> table.split "a" }

    "has 10 groups": (node) ->
      node.setInput 0, makeTable(10)
      node.on '0', (id, idx, datas) ->
        assert.equal 10, _.size(datas)

    "when cloned":
      topic: (node) -> node.clone()

      "still has 10 groups": (node) ->
        node.setInput 0, makeTable(10)
        node.on '0', (id, idx, datas) ->
          assert.equal 10, _.size(datas)





suite.export module
