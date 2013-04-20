require "../env"
vows = require "vows"
assert = require "assert"


makeTable = (nrows=100) ->
    rows = _.map _.range(nrows), (i) -> {a:1+i, b:i%10, id:i}
    gg.RowTable.fromArray rows




suite = vows.describe "position.coffee"

suite.addBatch
  "interpolate":
    topic: ->
      pts = _.map _.range(5), (i) -> {x:(1+i)*5, y:i}
      table = gg.RowTable.fromArray pts
      xs = [-1, 1, 5, 9, 10, 25, 100]
      [xs, table.raw()]
    "runs": ([xs, pts]) ->
      results =  gg.StackPosition.interpolate(xs, pts)
      assert.arrayEqual [0, 0, 0, 0.8, 1, 4, 0], _.pluck(results, 'y')

  "stack":
    topic: ->
      line1 = [
        {x: 0, y: 0},
        {x: 10, y: 10},
        {x: 20, y: 20}
      ]
      line2 = [
        {x: 5, y: 5},
        {x: 15, y: 15},
        {x: 25, y: 25}
      ]
      table = [
        {group: 'line1', 'pts': line1},
        {group: 'line2', 'pts': line2}
      ]

      gg.RowTable.fromArray table
    "can be stackde": (table) ->
      pos = new gg.StackPosition# {g: new gg.Graphic}
      pos.compute table



suite.export module
