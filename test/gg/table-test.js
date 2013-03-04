require("../env")


var vows = require("vows"),
    assert = require("assert");



var suite = vows.describe("table.js");

suite.addBatch({
    "row table": {
        topic: function() {
            var rows = _.map(_.range(100), function(i) { return {a:i, b:i%10, id:i};})
            var t = new gg.gg.RowTable(rows);
            this.callback(null, t);
       },
        "is correct shape": function(err, table) {
            assert.isNull (err);
            assert.equal (table.ncols(), 3);
            assert.equal (table.nrows(), 100);


        },
        "split on b": {
            topic: function(table) {
               return table.split(function(row) { return row['b']})
           },
            "has 10 partitions": function(splits) {
                assert.equal (_.size(splits), 10);
            },
        },
        "transformed on b": {
            topic: function(table) {
               return table.transform('b', function(v) { return -v })
            },
            "is negative": function(table) {
                _.each(_.range(table.nrows()), function(i) {
                    assert.lt (table.get(i,'b'), 0)
                });
            }
        },
        "adding unequal column should fail": function(table) {
            assert.throws(function() {
                table.addColumn("foo", []);
            }, Error);
        },
        "can add valid column": function(table) {
            table.addColumn("d", _.range(table.nrows()));
            assert.equal (table.ncols(), 4);
        }

    }
});


suite.export(module)
