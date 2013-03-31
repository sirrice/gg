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



suite.addBatch
  "color scale":
    topic: -> new gg.ColorScale {aes: "fill"}

    "can call the functions": (s) ->
      s.domain()
      s.range()
      s.d3()
      s.minDomain()
      s.maxDomain()
      s.minRange()
      s.maxRange()

    "after merging as discrete":
      topic: (s) ->
        s = s.clone()
        s.mergeDomain(_.range(10))
        s

      "can call the functions": (s) ->
        console.log s.domain().length
        s.range()
        console.log s.d3()
        s.minDomain()
        s.maxDomain()
        s.minRange()
        s.maxRange()

    "after merging 100 vals":
      topic: (s) ->
        s = s.clone()
        s.mergeDomain(_.range(100))
        s

      "can call the functions": (s) ->
        console.log s.domain().length
        s.range()
        console.log s.d3()
        s.minDomain()
        s.maxDomain()
        s.minRange()
        s.maxRange()



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
    topic:
      new gg.ScaleFactory
        a:
          type: "linear"
        b:
          type: "linear"


    "creates scales":
      topic: (factory) ->
        scales = factory.scales(['a', 'b'])
        scales.scale('a').range([0, 100])
        scales.scale('b').range([2,5])
        scales


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


  "linear scales factory with set range":
    topic:
      new gg.ScaleFactory
        a:
          type: "linear"
          range: [40, 1000]

    "creates scales":
      topic: (factory) -> factory.scales(['a'])

      "when trained on table":
        topic: (scales) ->
          scales.train makeTable 100
          scales

        "has original range": (scales) ->
          assert.arrayEqual scales.scale('a').range(), [40, 1000]
          assert.arrayEqual scales.scale('a').clone().range(), [40, 1000]
          assert.arrayEqual scales.clone().scale('a').range(), [40, 1000]


        "has trained domain": (scales) ->
          assert.arrayEqual scales.scale('a').domain(), [0, 99]
          assert.arrayEqual scales.scale('a').clone().domain(), [0, 99]
          assert.arrayEqual scales.clone().scale('a').domain(), [0, 99]

    "creates 2 scales":
      topic: (factory) ->
        [factory.scales(['a']), factory.scales(['a'])]

      "when trained on different tables":
        topic: ([ss1, ss2]) ->
          ss1.train makeTable 100
          ss2.train makeTable 500
          [ss1, ss2]

        "have different domains": ([ss1, ss2]) ->
          assert.arrayEqual ss1.scale('a').domain(), [0, 99]
          assert.arrayEqual ss2.scale('a').domain(), [0, 499]

        "when merged":
          topic: ([ss1, ss2]) ->
            gg.ScalesSet.merge [ss1, ss2]

          "has domain [0, 499]": (scales) ->
            assert.arrayEqual scales.scale('a').domain(), [0, 499]

  "color scales factory":
    topic:
      new gg.ScaleFactory
        a:
          type: "color"

    "creates scales":
      topic: (factory) -> factory.scales(['a'])

      "that are color scales": (scales) ->
        assert.equal scales.scale('a').type, 'color'
        assert.equal scales.scale('a').constructor.name, 'ColorScale'

      "when trained on small table":
        topic: (scales) ->
          scales = scales.clone()
          table = new gg.RowTable _.map(_.range(10), (i) -> {a:i})
          scales.train table
          scales

        "should be discrete": (scales) ->
          assert.arrayEqual scales.scale('a').domain(), _.range(10)
          #assert.equal scales.scale('a').isDiscrete, yes

      "when trained on big numeric table":
        topic: (scales) ->
          scales = scales.clone()
          table = new gg.RowTable _.map(_.range(50), (i) -> {a:i})
          scales.train table
          scales

        "should not be discrete": (scales) ->
          assert.arrayEqual scales.scale('a').domain(), _.range(50)# [0, 49]

      "when trained on small string table":
        topic: (scales) ->
          scales = scales.clone()
          table = new gg.RowTable _.map(_.range(5), (v) -> {a: ""+v})
          scales.train table
          scales

        "should be discrete": (scales) ->
          assert.arrayEqual scales.scale('a').domain(), _.map(_.range(5), String)
          #assert.equal scales.scale('a').isDiscrete,  yes












suite.export module

