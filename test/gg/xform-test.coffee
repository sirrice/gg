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
  "Exec" :
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

  "TableSource" :
    topic: new gg.wf.TableSource 
      params: 
        table: makeTable()

    "outputs a single table": (node) ->
      node.on '0', (id, idx, datas) ->
        for data in datas
          assert.equal 100, table.nrows()
      node.run()

  "Partition" :
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

  "Split":
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


  "GroupBy":
    topic: new gg.xform.GroupBy
      params:
        n: 5
        gbAttrs: ['x', 'z']
        aggFuncs:
          'avg': 'avg'
          'customname': 'sum'
          'customarg': { type: 'sum', arg: 't' }
          'count': 'count'

    'when executed':
      topic: (node) ->
        rows = _.times 1000, (i) ->
          if i < 12 
            { x: NaN, y: NaN }
          else if i < 20
            { x: i % 2, z: i % 5, y: NaN, t: null }
          else
            { x: i % 2, z: i % 5, y: 10, t: -10 }
        table = gg.data.RowTable.fromArray rows

        #gg.util.Log.setDefaults { "": 0 }
        set = new gg.scale.Set(
          gg.scale.Config.fromSpec({z: 'linear', t: 'linear'}).factoryFor 0
        )

        set.train table, {}
        env = new gg.wf.Env { scales: set }


        data = new gg.wf.Data table, env
        data = gg.xform.GroupBy.compute data, node.params
        data

      "has 10 rows": (data) ->
        assert.equal data.table.nrows(), 10

      "aggregates are correct": (data) ->
        data.table.each (row) ->
          assert.equal row.get('customname'), -row.get('customarg')
          assert.equal row.get('avg'), 10






suite.export module
