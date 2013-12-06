require "../env"
events = require "events"
vows = require "vows"
assert = require "assert"

suite = vows.describe "axis layout"

svg = d3.select('body').append('svg')
el = svg.append('g')

getstring = (n) ->
  _.times(n, () -> "-").join("")

suite.addBatch 
  "xscale":
    topic: ->
      s = new gg.scale.Ordinal { aes: 'x' }
      

    "5 labels, 2 chars":
      topic: (s) -> 
        s.domain _.times(5, () -> getstring(2))

      "layout x":
        topic: (s) ->
          b = new gg.util.Bound 0, 0, 200, 200
          em = _.exSize()
          gg.facet.axis.Layout.layoutYAxis b, em, s, el

        print: (opts) ->
          console.log opts




suite.export module
