require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "table.js"
Schema = gg.data.Schema
Transform = gg.data.Transform

schemaCheck = 
  "can be turned to json and parsed back": (table) ->
    table2 = table.clone()

    assert.deepEqual table.schema.toJSON(), table2.schema.toJSON()
    _.times table.nrows(), (idx) ->
      assert.equal table.get(idx, 'a'), table2.get(idx, 'a'), "a's should be equal: #{table.get(idx, 'a')} != #{table2.get(idx, 'a')}"

  "has correct schema": (table) ->
    schema = table.schema
    _.each ['a', 'b', 'c', 'id', 'nest'], (col) ->
      assert schema.has(col), "#{col} not found"
    _.each ['a', 'b', 'c'], (col) ->
      assert schema.isNumeric(col), "#{col} not numeric"

  "is correct shape": (table) ->
    assert.equal table.ncols(), 5
    assert.equal table.nrows(), 20

  "sort on a": 
    topic: (table) ->
      cmp = (r1, r2) -> r2.get('a') - r1.get('a')
      Transform.sort table, cmp

    "is actually sorted": (table) ->
      col = table.getColumn('a')
      for i in [0...col.length-1]
        assert.lt col[i+1], col[i]

  "each works": (table) ->
    table.each (row) ->
      assert.lt row.get('c'), 2

  "iterator works": (table) ->
    iter = table.iterator()
    while iter.hasNext()
      row = iter.next()
      assert.lt row.get('c'), 2

  "filter on a": (table) ->
    console.log(table.get(0).raw())
    console.log(table.klass().name)
    t = Transform.filter table, (row) -> row.get('c') == 0
    t.each (row) ->
      assert.equal 0, row.get('c')

  "split on b":
    topic: (table) -> 
      Transform.split table, 'b'

    "has 10 partitions": (splits) -> 
      assert.equal _.size(splits), 10

  "map on b": (table) ->
    t = Transform.map table, [
      ['b', ((row) -> -row.get('b')), Schema.numeric]
    ]
    assert.equal t.schema.ncols(), 1
    assert.deepEqual t.schema.cols[0], 'b'

  "transformations on b":
    "using function":
      topic: (table) ->
        Transform.transform table, [
          ['b', ((v) -> -v.get('b')), Schema.numeric]
        ]

      "is negative": (table) ->
        table.each (row) -> assert.lte row.get('b'), 0

    "using two key object":
      topic: (table) ->
        mapping = {
          a: (v) -> v.get 'a'
          b: (v) -> -v.get 'b'
          c: (v) -> v.get 'a'
        }
        mapping = _.map mapping, (f,k) -> [k,f,Schema.numeric]
        Transform.transform table, mapping

      "is correct": (table) ->
        table.each (row) ->
          assert.lte row.get('b'), 0
          assert.equal row.get('a'), row.get('c')


  ###
  "can add valid column": (table) ->
    table = table.clone()
    table = table.addColumn "d", _.range(table.nrows())
    assert.equal table.ncols(), 6
  ###

  "after adding column 't'":
    topic: (table) ->
      table.clone().setColumn 't', 99
    "has 't'": (table) ->
      assert table.has('t')
      assert table.schema.has('t')
      table.each (row) ->
        assert.equal row.get('t'), 99

    "after removing column 't'":
      topic: (table, orig) -> [table.rmColumn('t'), orig]

      "dosent have t": ([table, orig]) ->
        for i in [0...table.nrows()]
          r1 = table.get i
          assert.false r1.has('t')
          r2 = orig.get i
          for col in table.schema.cols
            assert.equal r1.get(col), r2.get(col)


  "with function column":
    topic: ->
      rows = _.map _.range(20), (i) ->
        a:i%10
        b: i
        id:""+i
        c: []
        d: { e: i}
      gg.data.Table.fromArray rows

    "has correct data": (table) ->
      valid = _.range(10)
      table.each (row, idx) ->
        assert.equal row.get('b'), idx
        assert.deepEqual {e:idx}, row.get('d')
        assert.include valid, row.get('a')




rowSchema = 
  topic: ->
    rows = _.times 20, (i) -> 
      {a:i+1, b:i%10, c: i%2,id:"#{i}",nest: {d:i, e:i}}
    gg.data.Table.fromArray rows, null, "row"
    
_.extend rowSchema, schemaCheck

colSchema = 
  topic: ->
    rows = _.times 20, (i) -> 
      {a:i+1, b:i%10, c: i%2,id:"#{i}",nest: {d:i, e:i}}
    gg.data.Table.fromArray rows, null, "col"
_.extend colSchema, schemaCheck

colSchema2 = 
  topic: ->
    a = _.times 20, (i) -> i+1
    b = _.times 20, (i) -> i%10
    c = _.times 20, (i) -> i%2
    id = _.times 20, (i) -> "#{i}"
    nest = _.times 20, (i) -> {d: i, e: i}
    schema = gg.data.Schema.fromJSON
      a: gg.data.Schema.numeric
      b: gg.data.Schema.numeric
      c: gg.data.Schema.numeric
      id: gg.data.Schema.ordinal
      nest: gg.data.Schema.object
    new gg.data.ColTable schema, [a, b, c, id, nest]
_.extend colSchema2, schemaCheck


multiSchema = 
  topic: ->
    rows = _.times 20, (i) -> 
      {a:i+1, b:i%10, c: i%2,id:"#{i}",nest: {d:i, e:i}}
    t = gg.data.Table.fromArray rows, null, "row"
    parts = Transform.split t, "c"
    new gg.data.MultiTable t.schema, _.map(parts, (o) -> o['table'])
_.extend multiSchema, schemaCheck

multiSchema2 = 
  topic: ->
    rows = _.times 20, (i) -> 
      {a:i+1, b:i%10, c: i%2,id:"#{i}",nest: {d:i, e:i}}
    t = gg.data.Table.fromArray rows, null, "col"
    parts = Transform.split t, "c"
    new gg.data.MultiTable t.schema, _.map(parts, (o) -> o['table'])
_.extend multiSchema2, schemaCheck

twoTables = 
  topic: ->
    os = _.times 20, (i) -> 
      {a:i+1, b:i%10, c: i%2,id:"#{i}",nest: {d:i, e:i}}
    rt = gg.data.Table.fromArray os, null, "row"
    ct = gg.data.Table.fromArray os, null, "col"
    [rt, ct]

  "functions are same": 
    "getcol": ([rt, ct]) ->
      assert.deepEqual rt.getCol('a'), ct.getCol('a')
    "raw": ([rt, ct]) ->
      assert.deepEqual rt.raw(), ct.raw()
    "get row": ([rt, ct]) ->
      assert.deepEqual rt.get(1), ct.get(1)
    "get row, col": ([rt, ct]) ->
      assert.equal rt.get(1, 'a'), ct.get(1, 'a')

  "when cloned": 
    topic: ([rt, ct]) ->
      [rt.clone(), ct.clone()]

    "has 20 rows": ([rt, ct]) ->
      assert.equal rt.nrows(), 20
      assert.equal ct.nrows(), 20

    "when const col added": 
      topic: ([rt, ct]) ->
        [rt.clone().setColumn('z', 10), ct.clone().setColumn('z', 10)]

      "has z": ([rt, ct]) ->
        assert rt.has('z')
        assert ct.has('z')

      "z is col of 10": ([rt, ct]) ->
        _.each rt.getCol('z'), (z) ->
          assert.equal z, 10
        _.each ct.getCol('z'), (z) ->
          assert.equal z, 10



suite.addBatch
#  "row table": rowSchema
  "col table": colSchema
  #  "col table2": colSchema2
  #  "multitable": multiSchema
  #  "multitable2": multiSchema2
  #  "two tables": twoTables


suite.export module
