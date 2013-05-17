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


suite.export module


