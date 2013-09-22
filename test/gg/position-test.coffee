require "../env"
vows = require "vows"
assert = require "assert"



suite = vows.describe "position.coffee"

suite.addBatch
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

      gg.data.RowTable.fromArray table

    "can be stacked": (table) ->
      pos = new gg.pos.Stack
      data = new gg.wf.Data table
      pos.setInput 0, [data]
      pos.run()

  "interpolate":
    topic: ()->
      pts = _.map _.range(5), (i) -> {x:(1+i)*5, y:i}
      table = gg.data.RowTable.fromArray pts
      xs = [-1, 1, 5, 9, 10, 25, 100]
      [xs, table.raw()]

    "runs": ([xs, pts]) ->
      results =  gg.pos.Interpolate.interpolate xs, pts
      assert.arrayEqual [0, 0, 0, 0.8, 1, 4, 0], _.pluck(results, 'y')





suite.export module
