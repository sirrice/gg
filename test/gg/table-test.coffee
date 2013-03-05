require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "table.js"

suite.addBatch {
    "row table": {
        topic: ->
            rows = _.map _.range(100), (i) -> {a:i, b:i%10, id:i}
            t = new gg.gg.RowTable(rows)
            this.callback null, t

        "is correct shape": (err, table) ->
            assert.isNull err
            assert.equal table.ncols(), 3
            assert.equal table.nrows(), 100

        "split on b":
            topic: (table) -> table.split (row) -> row['b']
            "has 10 partitions": (splits) -> assert.equal _.size(splits), 10

        "transformed on b":
            topic: (table) -> table.transform 'b', (v) -> -v
            "is negative": (table) ->
                _.each _.range(table.nrows()), (i) ->
                    assert.lt table.get(i,'b'), 0

        "adding unequal column should fail": (table) ->
            f = () -> table.addColumn "foo", []
            assert.throws f, Error

        "can add valid column": (table) ->
            table.addColumn "d", _.range(table.nrows())
            assert.equal table.ncols(), 4

    }
}


suite.export module
