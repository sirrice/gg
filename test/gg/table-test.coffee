require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "table.js"

suite.addBatch
  "nested row table":
    topic: ->
      rows = _.map _.range(100), (i) -> {a:i+1, b:i%10, c: i%2, id:i, nest: {d: i, e: i} }
      t = new gg.RowTable(rows)
      @callback null, t

    "has correct attrs": (err, table) ->
      attrs = table.get(0).attrs()
      _.each ['a', 'b', 'c', 'id', 'd', 'e'], (attr) ->
        assert.equal (attr in attrs), true


  "row table":
    topic: ->
        rows = _.map _.range(100), (i) -> {a:i+1, b:i%10, c: i%2,id:i}
        t = new gg.RowTable(rows)
        this.callback null, t

    "is correct shape": (err, table) ->
        assert.isNull err
        assert.equal table.ncols(), 4
        assert.equal table.nrows(), 100

    "split on b":
        topic: (table) -> table.split (row) -> row.get 'b'
        "has 10 partitions": (splits) -> assert.equal _.size(splits), 10

    "transformations on b":

        "using function":
            topic: (table) -> table.transform 'b', ((v) -> -v.get('b')), no

            "is negative": (table) ->
                table.each (row) -> assert.lte row.get('b'), 0

        "using lookup":
            topic: (table) -> table.transform 'b', 'a', no
            "has same value as attr 'a'": (table) ->
                table.each (row, idx) -> assert.lte 0, row.get('b')

        "using string eval":
            topic: (table) -> table.transform 'b', '{a + 200}', no
            "b is above 200": (table) ->
                table.each (row, idx) -> assert.lte 200, row.get('b')

        "using single key object":
            topic: (table) -> table.transform {b: ((v)->-v.get('b'))}, no
            "is negative": (table) ->
                table.each (row) -> assert.lte row.get('b'), 0

        "using two key object":
            topic: (table) -> table.transform {b: ((v)->-v.get('b')), c: 'a', d: "{a+200}", a: 'a'}, no
            "is correct": (table) ->
                table.each (row) ->
                    assert.lte row.get('b'), 0
                    assert.equal row.get('a'), row.get('c')
                    assert.lt 200, row.get('d')


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
            rows = _.map _.range(100), (i) -> {a:i%10, b: f, id:i}
            new gg.RowTable(rows)
        "has correct data": (table) ->
            valid = _.range(10)
            table.each (row) ->
                assert.equal (row.get('b') % 2), 1
                assert.lt 0, row.get('b')
                assert.include valid, row.get('a')







suite.export module
