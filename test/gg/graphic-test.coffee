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
  gg.data.RowTable.fromArray rows


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
        type: "area"
        aes:
          x: 'd'
          y: 'r'
      pos: "stack"
    }
  ]
  ###
    {
      # post-stats mapping (e.g., count --> y)
      geom: {type:"interval", aes: {y:"total", r:"total", fill: "red"}},
      # pre-stats mapping (to be consumed, and to split on discrete attributes)
      aes:
        x: "d"
        y: "r"
        fill: 'f'
        r: "r"
        "fill-opacity": 0.6
      # positioning
      pos: {type:"jitter", scale: 0.2}
      stat: {type:"bin", name: "rect-bin"}

    }
   ,
    {
      # post-stats mapping (e.g., count --> y)
      geom:
        type:"point" #, aes: {y:"total", r:"total",}},
      # pre-stats mapping (to be consumed, and to split on discrete attributes)
      aes:
        x: "d"
        y: "r"
        fill: 'f'
        r: "r"
        "fill-opacity": 0.6
      # positioning
      #pos: {type:"jitter", scale: 0.2}
      #stat: {type:"bin", name: "point-bin"}

    }
    ###

  facets:
    x: "f"
    y: "g"
  scales:
    #x:
    #  type: "log"
    r:
      type: "linear"
      range: [2, 5]

spec =
  layers: [
    {
      geom: "boxplot"
      aes:
        x: 'f'
        y: "e"
        group:
          color: "f"
      stats: "boxplot"
    }
    {
      geom: "point"
      aes:
        x: "g"
        y: "e"
        group:
          color: "g"
    }
  ]
  facets:
    x: "t"


spec =
  layers: [
    {
      geom: "boxplot"
      aes:
        x: 'f'
        y: "e"
        group:
          color: "f"
      stats: "boxplot"
    }
  ]
  facets:
    x: "t"



suite.addBatch
  "basic graphic":
    topic: ()->
      graphic = new gg.core.Graphic spec
      graphic

    "dot": (graphic) ->
      console.log graphic.compile().toDot()

    "can run": (graphic) ->
      svg = d3.select("body").append("svg")
      graphic.render 500, 500, svg, makeTable(100)

suite.export module
