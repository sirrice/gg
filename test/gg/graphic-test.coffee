require "../env"
vows = require "vows"
assert = require "assert"

makeTable = (nrows=100) ->
  rows = _.map _.range(0, nrows), (d) ->
    g = Math.floor(Math.random() * 3) + 1
    f = Math.floor(Math.random() * 3)
    t = Math.floor(Math.random() * 3)
    {
      d:d
      e:d# 1 + t * 0.5 + Math.abs(Math.random()) + g
      g: g
      f:f
      t:t
    }
  data.RowTable.fromArray rows


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
Math.seedrandom "zero"

# spec formats:
# {
#   type: XXX
#   aes: { .. mapping inserted before actual xform .., group: xxx }
#   args: { .. parameters accessible through @param .. }
# }

spec =
  layers: [
    {
      geom:
        type: "point"
        aes:
          y: 'sum'
      pos: "dot"
    }
  ]
  aes:
    x: 'e'

  opts:
    optimize: ['debug', 'server', 'barrier']

  facets:
    x: "t"

  debug:
    'gg.wf.runner': 0

  data: makeTable(100)

suite.addBatch
  "basic graphic":
    topic: ()->
      graphic = new gg.core.Graphic spec
      graphic


    "can run": (graphic) ->
      svg = d3.select("body").append("svg")
      graphic.render svg

suite.export module
