require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "schema.coffee"

Schema = gg.data.Schema

suite.addBatch
  "schema":
    topic: ->
      Schema.fromJSON
        x: Schema.numeric
        y: Schema.numeric




suite.export module
