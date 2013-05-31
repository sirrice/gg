require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "row.coffee"

Schema = gg.data.Schema
Row = gg.data.Row

suite.addBatch
  "nested row":
    topic: ->
      row =
        a: 0
        nested:
          b: 0
          c: 0
        pts: [
          { x: 0}
          { x: 1}
        ]
        pts2: [
          { y: 2}
          { y: 3}
          { y: 4}
        ]

      schema = Schema.fromSpec
        a: Schema.numeric
        nested:
          type: Schema.nested
          schema:
            b: Schema.numeric
            c: Schema.numeric
        pts:
          type: Schema.array
          schema:
            x: Schema.numeric
        pts2:
          type: Schema.array
          schema:
            y: Schema.numeric


      new Row row, schema


    "when all flattened":
      topic: (row) -> row.flatten()

      "has correct schema": (table) ->
        schema = table.schema
        _.each ['a', 'b', 'c'], (attr) ->
          assert schema.isNumeric(attr), "#{attr} should be numeric"
          assert schema.isRaw(attr), "#{attr} should be raw"

        _.each ['pts', 'pts2'], (attr) ->
          assert schema.contains(attr), "#{attr} should exist"
          assert schema.isNested(attr), "#{attr} should exist"

        assert.not schema.contains("nested")

    "when all flattened recursively":
      topic: (row) -> row.flatten(null, true)

      "has correct schema": (table) ->
        schema = table.schema
        _.each ['a', 'b', 'c', 'x', 'y'], (attr) ->
          assert schema.isNumeric(attr), "#{attr} should be numeric"
          assert schema.isRaw(attr), "#{attr} should be raw"

        _.each ['pts', 'pts2', 'nested'], (attr) ->
          assert.not schema.contains("nested"), "#{attr} should not be there"


    "when only pts is flattened":
      topic: (row) -> row.flatten("pts")

      "has correct schema": (table) ->
        schema = table.schema
        assert schema.isNumeric("a"), "a should be numeric"
        assert schema.isRaw("a"), "a should be raw"
        assert.not schema.isRaw('c'), "c should still be in nested"
        assert schema.isNested("nested"), "nested should still be nested"
        assert schema.isNested("pts"), "pts should be promoted to nested"
        assert schema.isArray("pts2"), "pts2 should still be array"

    "when only pts is flattened recursively":
      topic: (row) -> row.flatten("pts", true)

      "has correct schema": (table) ->
        schema = table.schema
        _.each ['a', 'x'], (attr) ->
          assert schema.isNumeric(attr), "#{attr} should be numeric"
          assert schema.isRaw(attr), "#{attr} should be raw"

        assert.not schema.isRaw('c'), "c should still be in nested"
        assert schema.isNested("nested"), "nested should still be nested"
        assert.not schema.contains("pts"), "pts should not exist"
        assert schema.isArray("pts2"), "pts2 should still be array"



suite.export module
