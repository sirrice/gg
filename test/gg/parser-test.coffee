require "../env"
vows = require "vows"
assert = require "assert"
events = require 'events'

suite = vows.describe "train.coffee"
Schema = data.Schema


suite.addBatch 
  "simple spec":
    topic: ->
      {
        geom: "point"
      }
    "when parsed": 
      topic: (spec) -> gg.parse.Parser.parse spec
      "is correct": (spec) ->
        assert.deepEqual spec, {"layers":[{"aes":{},"data":null,"geom":{"type":"point","aes":{}},"scales":{},"coord":{"type":"identity","aes":{}},"stat":{"type":"identity","aes":{}},"pos":{"type":"identity","aes":{}}}],"facets":{"type":"none","aes":{},"x":null,"y":null},"debug":{},"options":{}}

  "2 layers":
    topic: ->
      {
        layers: [
          {
            geom: 
              type: "rect"
              aes: 
                x: 'a'

            scales: {}, 
            pos: "dodge", facets: {}
          }
          {
            aes:
              y: 'c'
              x: 'a'
            geom: 'point'
          }
        ]
        geom: "point"
        aes: 
          y: 'b'
        facets: "y"
        scales: { x: 'color'}

      }

    "when parsed": 
      topic: (spec) -> gg.parse.Parser.parse spec
      "is correct": (spec) ->
        assert.deepEqual spec, { layers: [ { aes: { y: 'b' }, data: undefined, geom: { type: 'rect', aes: { x: 'a' } }, scales: { x: { type: 'color', aes: {} } }, coord: { type: 'identity', aes: {} }, stat: { type: 'identity', aes: {} }, pos: { type: 'dodge', aes: {} } }, { aes: { y: 'c', x: 'a' }, data: undefined, geom: { type: 'point', aes: {} }, scales: { x: { type: 'color', aes: {} } }, coord: { type: 'identity', aes: {} }, stat: { type: 'identity', aes: {} }, pos: { type: 'identity', aes: {} } } ], facets: { type: 'none', aes: {}, x: null, y: null }, debug: {}, options: {} }








suite.export module