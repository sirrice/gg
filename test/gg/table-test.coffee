require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "table.js"
Schema = gg.data.Schema

suite.addBatch
  "nested row table":
    topic: ->
      rows = _.map _.range(2), (i) ->
        a:i+1
        b:i%10
        c: i%2
        id:i
        nest: {d: i, e: i}
        arr: [{f: i*1}, {f: i*2}, {f:i*3}]
      t = gg.data.RowTable.fromArray rows
      t

    "has correct schema": (table) ->
      schema = table.schema
      _.each ['a', 'b', 'c', 'id', 'nest', 'arr'], (key) ->
        assert schema.isKey(key), "key #{key} not found"
      assert schema.isTable('arr'), "arr not a table"
      assert schema.isNested('nest'), "nest not a nested"
      _.each ['d', 'e', 'f'], (key) ->
        assert schema.isNumeric(key), "#{key} should be a number"

    "rows have correct composite keys": (table) ->
      table.each (row) ->
        assert ("nest" in row.nestedKeys())
        assert ("arr" in row.arrKeys())

    "has correct attrs": (table) ->
      attrs = table.colNames()
      _.each ['arr', 'a', 'b', 'c', 'id', 'd', 'e', 'f'], (attr) ->
        assert (attr in attrs)
        table.each (row) ->
          assert row.hasAttr(attr)

    "correct nested attrs": (table) ->
      table.each (row, i) ->
        assert.equal row.get("d"), i
        assert.equal row.get("e"), i

    "correct array attrs": (table) ->
      table.each (row, i) ->
        vals = row.get('f')
        assert.equal vals[0], (i*1)
        assert.equal vals[1], (i*2)
        assert.equal vals[2], (i*3)

    "flattens correctly": (table) ->
      flattened = table.flatten()
      assert.equal table.nrows() * 3, flattened.nrows()
      flattened.each (row, i) ->
        _.each ['a', 'b', 'c', 'id', 'd', 'e', 'arr'], (attr) ->
          assert (attr in row.rawKeys()), "#{attr} should be a raw key"
        _.each ['nested'], (attr) ->
          assert.not row.contains(attr), "#{attr} should not exist anymore"
        assert row.contains("f"), "f should still be in the row"

    "flattens recursively correctly": (table) ->
      flattened = table.flatten(null, true)
      assert.equal table.nrows() * 3, flattened.nrows()
      flattened.each (row, i) ->
        _.each ['a', 'b', 'c', 'id', 'd', 'e', 'f'], (attr) ->
          assert (attr in row.rawKeys()), "#{attr} should be a raw key"
        _.each ['neste', 'arr'], (attr) ->
          assert.not row.contains(attr), "#{attr} should not exist anymore"

    "can be turned to json and parsed back": (table) ->
      table2 = gg.data.RowTable.fromJSON table.toJSON()

      assert.deepEqual table.schema.toJSON(), table2.schema.toJSON()
      _.times table.nrows(), (idx) ->
        assert.equal table.get(idx, 'a'), table2.get(idx, 'a'), "a's should be equal"
        assert.deepEqual table.get(idx, 'f'), table2.get(idx, 'f'), "arrays should be equal"

    "transforms to first schema correctly": (table) ->
      targetSchema = Schema.fromSpec
        a: Schema.numeric
        f: Schema.numeric
        d: Schema.numeric
        nest:
          type: Schema.nested
          schema:
            b: Schema.numeric
        arr:
          type: Schema.array
          schema:
            c: Schema.numeric

      newtable = gg.data.SchemaMap.transform table, targetSchema
      newtable.each (row, idx) ->
        assert _.isNumber(row.get("a")), "a should be numeric"
        assert _.isNumber(row.get("f")), "f should be numeric"
        assert _.isNumber(row.get('d')), "d should be numeric"
        assert _.isObject(row.get("nest")), "nest should be an object"
        assert _.isNumber(row.get("b")), "b should be numeric"
        assert _.isArray(row.get("arr")), "arr should be array"
        for v in row.get("c")
          assert _.isNumber(v), "c be array"

    "when f is set":
      topic: (table) ->
        table = table.clone()
        table.each (row) -> row.set('f', [10, 11, 12])
        table

      "f is correctly set": (table) ->
        table.each (row) ->
          assert.equal row.inArray('f'), true
          assert.arrayEqual [10, 11, 12], row.get('f')

    "when scales are applied then inverted":
      topic: (table) ->
        table = table.clone()
        sf = gg.scale.Config.fromSpec {f: {domain: [0, 300], range: [500, 800]}}
        scales = sf.scales(['f'])
        applied = scales.apply table, ['f']
        inverted = scales.invert applied, ['f']
        [scales, table, applied, inverted]

      "does not corrupt original table": ([scales, table, applied, inverted]) ->
        table.each (row, idx) ->
          assert.arrayEqual [idx*1,idx*2,idx*3], row.get('f')
        applied.each (row, idx) ->
          assert.arrayEqual [idx*1+500,idx*2+500,idx*3+500], row.get('f')
        inverted.each (row, idx) ->
          assert.arrayEqual [idx*1,idx*2,idx*3], row.get('f')






  "row table":
    topic: ->
      rows = _.map _.range(100), (i) -> {a:i+1, b:i%10, c: i%2,id:i}
      t = gg.data.RowTable.fromArray rows
      t

    "is correct shape": (table) ->
      assert.equal table.ncols(), 4
      assert.equal table.nrows(), 100

    "split on b":
      topic: (table) -> table.split (row) -> row.get 'b'
      "has 10 partitions": (splits) -> assert.equal _.size(splits), 10

    "transformations on b":

      "using function":
        topic: (table) ->
          table.transform 'b', ((v) -> -v.get('b')), no

        "is negative": (table) ->
          table.each (row) -> assert.lte row.get('b'), 0


      "using single key object":
        topic: (table) -> table.transform {b: ((v)->-v.get('b'))}, no
        "is negative": (table) ->
          table.each (row) -> assert.lte row.get('b'), 0

      "using two key object":
        topic: (table) ->
          table.transform {
            a: (v) -> v.get 'a'
            b: (v) -> -v.get 'b'
            c: (v) -> v.get 'a'
          }, no

        "is correct": (table) ->
          table.each (row) ->
            assert.lte row.get('b'), 0
            assert.equal row.get('a'), row.get('c')


    "adding unequal column should fail": (table) ->
      f = () -> table.addColumn "foo", []
      assert.throws f, Error

    "can add valid column": (table) ->
      table.addColumn "d", _.range(table.nrows())
      assert.equal table.ncols(), 5

    "with function column":
      topic: ->
        v = 1
        f = () ->
            v += 2
            v
        rows = _.map _.range(100), (i) ->
          a:i%10
          b: f
          id:i
          c: []
          d: { e: f}
          f: [{g:f}]
        gg.data.RowTable.fromArray rows

      "has correct data": (table) ->
        valid = _.range(10)
        table.each (row) ->
          assert.equal (row.get('b') % 2), 1
          assert.lt 0, row.get('b')
          assert.lt 0, row.get('e')
          _.each row.get('g'), (v) -> assert.lt 0, v
          assert.include valid, row.get('a')


suite.export module
