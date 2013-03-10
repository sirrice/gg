require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "table.js"

suite.addBatch {
    "row table": {
        topic: ->
            rows = _.map _.range(100), (i) -> {a:i+1, b:i%10, c: i%2,id:i}
            t = new gg.RowTable(rows)
            this.callback null, t

        "is correct shape": (err, table) ->
            assert.isNull err
            assert.equal table.ncols(), 4
            assert.equal table.nrows(), 100

        "split on b":
            topic: (table) -> table.split (row) -> row['b']
            "has 10 partitions": (splits) -> assert.equal _.size(splits), 10

        "transformations on b":

            "using function":
                topic: (table) -> table.transform 'b', ((v) -> -v), no

                "is negative": (table) ->
                    table.each (row) -> assert.lte row.get('b'), 0

            "using lookup":
                topic: (table) -> table.transform 'b', 'a', no
                "has same value as attr 'a'": (table) ->
                    table.each (row, idx) -> assert.lte 0, row.get('b')

            "using string eval":
                topic: (table) -> table.transform 'b', 'a + 200', no
                "b is above 200": (table) ->
                    table.each (row, idx) -> assert.lte 200, row.get('b')

            "using single key object":
                topic: (table) -> table.transform {b: ((v)->-v)}, no
                "is negative": (table) ->
                    table.each (row) -> assert.lte row.get('b'), 0

            "using two key object":
                topic: (table) -> table.transform {b: ((v)->-v), c: 'a', d: "a+200", a: 'a'}, no
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

    }
}


suite.export module
