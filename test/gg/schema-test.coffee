require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "schema.coffee"

Schema = gg.data.Schema

suite.addBatch
  "schema":
    topic: ->
      Schema.fromSpec
        x: Schema.numeric
        y: Schema.numeric
        nested:
          type: Schema.nested
          schema:
            z: Schema.numeric

    "flattens correctly": (schema) ->
      schema = schema.flatten()
      _.each ['x', 'y', 'z'], (attr) ->
        assert schema.contains attr
        assert schema.isNumeric attr
      assert.not schema.contains("nested")

  "pts schema":
    topic: ->
      Schema.fromSpec
        a: Schema.numeric
        pts:
          type: Schema.array
          schema:
            x: Schema.numeric
            y: Schema.numeric

    "can extract from proper row": (schema) ->
      row = pts: [ {x:0, y: 0}, {x:1, y:1}, {x:5, y: 10}]
      assert.arrayEqual schema.extract(row, 'x'), [0, 1, 5]
      assert.arrayEqual schema.extract(row, 'y'), [0, 1, 10]

    "extracting attr not in data returns null": (schema) ->
      row = pts: [ {x:0, y: 0}, {x:1, y:1}, {x:5, y: 10}]
      assert.equal schema.extract(row, 'a'), null

    "extracting attr not in schema throws error": (schema) ->
      row = pts: [ {x:0, y: 0}, {x:1, y:1}, {x:5, y: 10}]
      assert.equal schema.extract(row, 'foo'), null

    "flatten non-recursively correctly": (schema) ->
      schema = schema.flatten()
      _.each ['x', 'y', 'a'], (attr) ->
        assert schema.contains attr
        assert schema.isNumeric attr
      assert.not schema.isRaw("x"), "x should not be a raw type"
      assert schema.isNested("pts"), "pts should be nested type"

    "flatten recursively correctly": (schema) ->
      schema = schema.flatten(null, true)
      _.each ['x', 'y', 'a'], (attr) ->
        assert schema.contains(attr), "#{attr} should be there"
        assert schema.isNumeric(attr), "#{attr} should be numeric"
        assert schema.isRaw(attr), "#{attr} should be raw"
      assert.not schema.contains("pts"), "pts should not be there"


  "data row1":
    topic: ->
      row =
        a: 0
        b: "foo"
        pts: [
          { x: 0, y: 0, t: 0},
          { x: 0, y: 1, z: "str", t: 0},
          { x: 0, z: "str", t: "str"}
        ]
        nested:
          nx: 0
          ny: 0
          nz: "str"

      row

    "table inference":
      topic: (row) ->
        schema = gg.data.Schema.infer [row]
        schema

      "infers correct schema": (schema) ->
        numeric = ['a', 'x', 'y', 'nx', 'ny']
        ordinal = ['b', 'z', 'nz', 't']
        _.each numeric, (attr) ->
          assert schema.isNumeric(attr), "'#{attr}' = #{schema.type attr} should be numeric"
        _.each ordinal, (attr) ->
          assert schema.isOrdinal(attr), "'#{attr}' = #{schema.type attr} should be ordinal"
        assert schema.isNested('nested'), "'nested' = #{schema.type 'nested'} should be nested"
        assert schema.isArray('pts'), "'pts' = #{schema.type 'pts'} should be array"





suite.export module
