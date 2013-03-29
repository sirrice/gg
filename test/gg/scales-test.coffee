require "../env"
vows = require "vows"
assert = require "assert"
suite = vows.describe "scales.coffee"

makeTable = (nrows=100) ->
  rows = _.map _.range(0, nrows), (d) ->
    {
      a: d
      b: d/2
      c: d*2
      d: d%5
      e: d%10
    }
  new gg.RowTable rows


spec =
  a:
    type: "linear"
    range: [0, 100]
  b:
    type: "linear"
    range: [2,5]

console.log gg

suite.addBatch
  "default scales":
    topic: ->
      scale = gg.Scale.defaultFor "x"
      scale.mergeDomain [0, 100]
      scale
    "has correct domain": (scale) ->
      assert.arrayEqual scale.domain(), [0, 100]

    "when cloned":
      topic: (scale) -> scale.clone()
      "has aesthetic": (scale) -> assert.equal scale.aes, "x"
      "has correct domain": (scale) ->
        assert.arrayEqual scale.domain(), [0, 100]


  "scales factory":
    topic: new gg.ScaleFactory spec

    "creates scales":
      topic: (factory) -> factory.scales(['a', 'b'])

      "when trained on table":
        topic: (scales) ->
          scales.train makeTable 100
          scales

        "has correct domain and range": (scales) ->
          assert.arrayEqual scales.scale('a').domain(), [0,99]
          assert.arrayEqual scales.scale('a').range(), [0, 100]
          assert.arrayEqual scales.scale('b').domain(), [0, 49.5]
          assert.arrayEqual scales.scale('b').range(), [2,5]

        "when cloned":
          topic: (scales) -> scales.clone()

          "has correct domain and range": (scales) ->
            assert.arrayEqual scales.scale('a').domain(), [0,99]
            assert.arrayEqual scales.scale('a').range(), [0, 100]
            assert.arrayEqual scales.scale('b').domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b').range(), [2,5]

        "when range is reversed":
          topic: (scales) ->
            scales.scale('a').range([100, 0])
            scales.scale('b').range([50, 0])
            scales


          "has correct domain and range": (scales) ->
            scales = scales.clone()
            assert.arrayEqual scales.scale('a').domain(), [0,99]
            assert.arrayEqual scales.scale('a').range(), [100, 0]
            assert.arrayEqual scales.scale('b').domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b').range(), [50, 0]

          "supports setting 'a''s scale": (scales) ->
            copy = scales.scale('a').clone()
            scales.scale(copy)
            assert.arrayEqual scales.scale('a').domain(), [0,99]
            assert.arrayEqual scales.scale('a').range(), [100, 0]
            assert.arrayEqual scales.scale('b').domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b').range(), [50, 0]







suite.export module

