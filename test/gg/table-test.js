require("../env")


var vows = require("vows"),
    assert = require("assert");

var suite = vows.describe("table.js");

suite.addBatch({
    "table": {
        topic: function() {
            var t = new gg.gg.RowTable;
            console.log("table: " + t)
            this.callback(null, t);
       },
        "is 1": function(err, val) {
            assert.isNull (err);
            assert.equal (val, 1);
        }
    }
});


suite.export(module)
