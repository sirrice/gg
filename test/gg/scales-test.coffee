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
  gg.RowTable.fromArray rows



suite.addBatch
  "color scale":
    topic: -> new gg.ColorScale {aes: "fill"}

    "is ordinal and not domain": (s) ->
      assert.arrayEqual [], s.domain()
      assert.equal gg.Schema.ordinal, s.type

    "after merging as discrete":
      topic: (s) ->
        s = s.clone()
        s.mergeDomain(_.range(5))
        s

      "scale is ordinal": (s) ->
        assert.arrayEqual s.domain(), _.range(5)
        assert.equal s.type, gg.Schema.ordinal

    "after merging 100 vals":
      topic: (s) ->
        s = s.clone()
        s.mergeDomain(_.range(100))
        s

      "scale is still ordinal": (s) ->
        assert.equal s.type, gg.Schema.ordinal
      "scale has discrete domain": (s) ->
        assert.arrayEqual  s.domain(), _.range(100)

  ###

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
      gg.ScaleConfig.fromSpec
        a:
          type: "linear"
        b:
          type: "linear"


    "creates scales":
      topic: (factory) ->
        scales = factory.scales(['a', 'b'])
        scales.scale('a', gg.Schema.unknown).range([0, 100])
        scales.scale('b', gg.Schema.unknown).range([2,5])
        scales


      "when trained on table":
        topic: (scales) ->
          scales.train makeTable 100
          scales

        "has correct domain and range": (scales) ->
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0,99]
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).range(), [0, 100]
          assert.arrayEqual scales.scale('b', gg.Schema.unknown).domain(), [0, 49.5]
          assert.arrayEqual scales.scale('b', gg.Schema.unknown).range(), [2,5]

        "when cloned":
          topic: (scales) -> scales.clone()

          "has correct domain and range": (scales) ->
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0,99]
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).range(), [0, 100]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).range(), [2,5]

        "when range is reversed":
          topic: (scales) ->
            scales.scale('a', gg.Schema.unknown).range([100, 0])
            scales.scale('b', gg.Schema.unknown).range([50, 0])
            scales


          "has correct domain and range": (scales) ->
            scales = scales.clone()
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0,99]
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).range(), [100, 0]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).range(), [50, 0]

          "supports setting 'a''s scale": (scales) ->
            copy = scales.scale('a', gg.Schema.unknown).clone()
            scales.scale(copy)
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0,99]
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).range(), [100, 0]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).domain(), [0, 49.5]
            assert.arrayEqual scales.scale('b', gg.Schema.unknown).range(), [50, 0]


  "linear scales factory with set range":
    topic:
      gg.ScaleConfig.fromSpec
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
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).range(), [40, 1000]
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).clone().range(), [40, 1000]
          assert.arrayEqual scales.clone().scale('a', gg.Schema.unknown).range(), [40, 1000]


        "has trained domain": (scales) ->
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0, 99]
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).clone().domain(), [0, 99]
          assert.arrayEqual scales.clone().scale('a', gg.Schema.unknown).domain(), [0, 99]

    "creates 2 scales":
      topic: (factory) ->
        [factory.scales(['a']), factory.scales(['a'])]

      "when trained on different tables":
        topic: ([ss1, ss2]) ->
          ss1.train makeTable 100
          ss2.train makeTable 500
          [ss1, ss2]

        "have different domains": ([ss1, ss2]) ->
          assert.arrayEqual ss1.scale('a', gg.Schema.unknown).domain(), [0, 99]
          assert.arrayEqual ss2.scale('a', gg.Schema.unknown).domain(), [0, 499]

        "when merged":
          topic: ([ss1, ss2]) ->
            gg.ScalesSet.merge [ss1, ss2]

          "has domain [0, 499]": (scales) ->
            assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), [0, 499]


  "color scales factory":
    topic:
      gg.ScaleConfig.fromSpec
        a:
          type: "color"

    "creates scales":
      topic: (factory) ->
        console.log factory.scales(['a'])
        factory.scales ['a']

      "that are color scales": (scales) ->
        assert.equal scales.scale('a', gg.Schema.unknown).type, gg.Schema.ordinal
        assert.equal scales.scale('a', gg.Schema.unknown).constructor.name, 'ColorScale'

      "when trained on small table":
        topic: (scales) ->
          scales = scales.clone()
          table = gg.RowTable.fromArray _.map(_.range(10), (i) -> {a:i})
          scales.train table
          console.log "post aess: #{scales.aesthetics()}"
          scales

        "should be discrete": (scales) ->
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), _.range(10)
          #assert.equal scales.scale('a').isDiscrete, yes

      "when trained on big numeric table":
        topic: (scales) ->
          scales = scales.clone()
          table = gg.RowTable.fromArray _.map(_.range(50), (i) -> {a:i})
          scales.train table
          scales

        "should not be discrete": (scales) ->
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), _.range(50)# [0, 49]

      "when trained on small string table":
        topic: (scales) ->
          scales = scales.clone()
          table = gg.RowTable.fromArray _.map(_.range(5), (v) -> {a: ""+v})
          scales.train table
          scales

        "should be discrete": (scales) ->
          assert.arrayEqual scales.scale('a', gg.Schema.unknown).domain(), _.map(_.range(5), String)
          #assert.equal scales.scale('a').isDiscrete,  yes

  "scales inverse":
    topic: gg.ScaleConfig.fromSpec
      a:
        type: "linear"
        domain: [0, 100]
        range: [10, 0]

    "inverse works": (sf) ->
      table = gg.RowTable.fromArray _.map(_.range(10), (i)->{a:i*10})
      scales = sf.scales(['a'])
      scales.train table
      newTable = scales.invert table
      console.log newTable.raw()
      origTable = scales.apply newTable
      console.log origTable.raw()
###









suite.export module

