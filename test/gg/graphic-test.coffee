require "../env"
vows = require "vows"
assert = require "assert"


makeTable = (nrows=100) ->
    rows = _.map _.range(nrows), (i) -> {a:1+i, b:i%10, id:i}
    new gg.RowTable(rows)


outputsProperlyGen = (check) ->

    (node) ->
        node = node.cloneSubplan()[0]
        node.addOutputHandler 0, (id, output) ->
            table = output.table
            table.each check

        t = makeTable(10)
        node.addInput(0, 0, t)
        node.run()



suite = vows.describe "graphic.coffee"

spec =
  layers: [
    {
      geom: "point"
      aes:
        x: "x"
        y: "y"
    }
  ]
  facets:
    x: "a"
    y: "b"
  scales:
    x:
      type: "linear"


suite.addBatch
  "basic graphic":
    topic: ()->
      graphic = new gg.Graphic spec
      graphic

    "can compile": (graphic) ->
      graphic.compile()


suite.export module

