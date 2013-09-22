require "../env"
vows = require "vows"
assert = require "assert"


suite = vows.describe "gg.wf.util"

suite.addBatch
  "UniqQueue":
    "empty":

      topic: ->
        new gg.util.UniqQueue

      "computes the key correctly": (q) ->
        assert.equal q.key(1), 1
        assert.deepEqual q.key({id:1}), {id:1}
        assert.deepEqual q.key({}), {}

      "pops what it pushes (only once)": (q) ->
        q.push 1
        assert.equal q.pop(), 1


    "initialized with ints":

      topic: -> new gg.util.UniqQueue [1, 2, 3]

      "contains [1,2,3]": (q) ->
        assert.equal q.pop(), 1
        assert.equal q.pop(), 2
        assert.equal q.pop(), 3
        assert.equal _.size(q.id2item), 0
        assert.equal _.size(q.list), 0

    "initialized with toString objects":
      topic: ->
        class Foo
          constructor: (@v) ->
          toString: -> "foo"
        new gg.util.UniqQueue _.map(_.range(10), (v)->new Foo v)

      "contains only 1 element": (q) ->
        assert.equal q.length(), 1


suite.export module
