require "../env"
vows = require "vows"
assert = require "assert"


makeTable = ->
    rows = _.map _.range(100), (i) -> {a:i, b:i%10, id:i}
    new gg.gg.RowTable(rows)




suite = vows.describe "xform.coffee"

suite.addBatch {
    "node xform" : {
        topic: new gg.Node((table) -> table.transform 'a', (v) -> -1)

        "outputs properly": (node) ->
            node.on "output", ([id, output]) ->
                for i in [0...output.nrows()]
                    assert.lt table.get(i, 'a'), 0

            node.addInput([0, makeTable()])
    }


}



