require "../env"
vows = require "vows"
assert = require "assert"


makeTable = (nrows=100) ->
    rows = _.map _.range(nrows), (i) -> {a:1+i, b:i%10, id:i}
    gg.RowTable.fromArray (rows)


outputsProperlyGen = (check) ->

    (node) ->
        node = node.cloneSubplan()[0]
        node.addOutputHandler 0, (id, output) ->
            table = output.table
            table.each check

        t = makeTable(10)
        node.addInput(0, 0, t)
        node.run()



suite = vows.describe "xform.coffee"

suite.addBatch
  "single node xform" :
    topic: new gg.wf.Exec
      f:(table) -> table.transform 'a', (v) -> -v.get('a')

    "runs compute correctly": (node) ->
        [node, x] = node.cloneSubplan()
        node.addInput(0, 0, makeTable(10))
        output = node.run()
        assert.equal 10, output.nrows()

    "outputs properly": outputsProperlyGen (row) ->
        assert.lt row.get('a'), 0

    "when cloned":
        topic: (node) -> node.clone(null)[0]
        "has a name": (node) ->
            assert.isNotNull node.name
        "outputs properly": outputsProperlyGen (row) ->
            assert.lt row.get('a'), 0

  "table source node" :
    topic: new gg.wf.TableSource {table: makeTable()}

    "outputs a single table": (node) ->
      node.addOutputHandler 0, (id, output) ->
        table = output.table
        assert.equal 100, table.nrows()
      node.run()

  "partition node" :
    topic: new gg.wf.Partition {f: (row) -> row.get('a')}

    "has 10 groups": (node) ->
      node.addInput(0, 0, makeTable(10))
      output = node.run()
      assert.equal 10, _.size(output)

    "whew cloned":
      topic: (node) -> node.clone(null)[0]

      "still has 10 groups": (node) ->
        node.addInput(0, 0, makeTable(10))
        output = node.run()
        assert.equal 10, _.size(output)

  "split node":
    topic: new gg.wf.Split {f: (table) -> table.split "a" }



    "has 10 groups": (node) ->
      node.addInput(0, 0, makeTable(10))
      output = node.run()
      assert.equal 10, _.size(output)

    "whew cloned":
      topic: (node) -> node.clone(null)[0]

      "still has 10 groups": (node) ->
        node.addInput(0, 0, makeTable(10))
        output = node.run()
        assert.equal 10, _.size(output)





suite.export module
