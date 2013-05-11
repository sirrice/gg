require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "schema.coffee"

suite.addBatch
  "schema":
    topic: ->
      gg.Schema.fromSpec
        q1: gg.Schema.numeric
        q3: gg.Schema.numeric
        median: gg.Schema.numeric
        lower: gg.Schema.numeric
        upper: gg.Schema.numeric
        outliers:
          type: gg.Schema.array
          schema:
            outlier: gg.Schema.numeric
        min: gg.Schema.numeric
        max: gg.Schema.numeric

    "looks good": (schema) ->
      console.log schema.toString()

  "pts schema":
    topic: ->
      gg.Schema.fromSpec
        pts:
          type: gg.Schema.array
          schema:
            x: gg.Schema.numeric
            y: gg.Schema.numeric

    "can extract from proper row": (schema) ->
      row =
        pts: [ {x:0, y: 0}, {x:1, y:1}, {x:5, y: 10}]
      assert.arrayEqual schema.extract(row, 'x'), [0, 1, 5]
      assert.arrayEqual schema.extract(row, 'y'), [0, 1, 10]



suite.export module
