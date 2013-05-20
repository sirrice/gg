require "../env"
vows = require "vows"
assert = require "assert"


suite = vows.describe "util.graph.coffee"

suite.addBatch
  "simple graph":
    topic: ()->
      graph = new gg.util.Graph (node) -> node
      graph.connect [
        ["A", "B"]
        ["A", "D"]
        ["A", "C"]
        ["B", "C"]
        ["C", "B"]
        ["D", "B"]
      ]
      graph

    "has no sinks": (graph) ->
      assert.equal graph.sinks().length, 0

    "has 1 source": (graph) ->
      assert.arrayEqual graph.sources(), ["A"]

    "a has 3 children": (graph) ->
      children = graph.children "A"
      _.each ["B", "C", "D"], (child) ->
        assert (child in children), "#{child} should not be A's child"

    "a has no parents": (graph) ->
      assert.equal graph.parents("A").length, 0

    "has 6 edges": (graph) ->
      assert.equal graph.edges().length, 6

    "bfs finds 5 nodes": (graph) ->
      nodes = []
      graph.bfs (node)->nodes.push node
      assert.equal nodes.length, 4

    "bfs from B finds 2 nodes": (graph) ->
      nodes = []
      graph.bfs ((node)->nodes.push node), "B"
      assert.equal nodes.length, 2

    "dfs finds 5 nodes": (graph) ->
      nodes = []
      graph.dfs (node)->nodes.push node
      assert.equal nodes.length, 4


    "after removing A":
      topic: (graph) ->
        graph.rm "A"
        graph

      "has 3 edges": (graph) ->
        assert.equal graph.edges().length, 3

      "A has no children": (graph) ->
        assert.equal graph.children("A").length, 0

  "graph with typed edges":
    topic: () ->
      graph = new gg.util.Graph (node)->node
      graph.connect [
        [1, 2, "a", 1]
        [1, 3, "a", 1]
        [1, 4, "b", 1]
        [2, 3, "a", 1]
        [2, 4, "b", 1]
        [3, 2, "a", 2]
      ]

    "1 has 3 children": (graph) ->
      assert.equal graph.children(1).length, 3

    "1 has 1 'b' children": (graph) ->
      assert.equal graph.children(1, 'b').length, 1

    "1 has 2 'a' children": (graph) ->
      assert.equal graph.children(1, 'a').length, 2

    "2 has 2 parents": (graph) ->
      assert.equal graph.parents(2).length, 2

    "2 has 2 'a' parents": (graph) ->
      assert.equal graph.parents(2, 'a').length, 2

    "there is 1 sink": (graph) ->
      assert.equal graph.sinks().length, 1

    "there is 1 source": (graph) ->
      assert.equal graph.sources().length, 1

    "certain edges exist": (graph) ->
      assert graph.edgeExists(2, 3)
      assert graph.edgeExists(2, 3, 'a')
      assert.equal graph.edgeExists(2, 3, 'b'), false

    "graph has 6 edges": (graph) ->
      assert.equal graph.edges().length, 6

    "graph has 4 'a' edges": (graph) ->
      assert.equal graph.edges('a').length, 4

    "graph has 1 'a' edges with metadata 2": (graph) ->
      assert.equal graph.edges('a', (v)->v==2).length, 1



suite.export module


