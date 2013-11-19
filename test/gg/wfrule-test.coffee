require "../env"
vows = require "vows"
assert = require "assert"

makeTable = (nrows=100) ->
    rows = _.map _.range(nrows), (i) -> {a:1+i, b:i%10, c: i%2, id:i}
    data.RowTable.fromArray (rows)



suite = vows.describe "gg.wf.rule.Rule"

genReplacement = (str) ->
  _.map str, (c) ->
    switch c
      when "E" then new gg.wf.Exec
      when "B" then new gg.wf.Barrier


suite.addBatch
  "exec-exec-exec":
    topic: ->
      n1 = new gg.wf.Exec
      n2 = new gg.wf.Exec
      n3 = new gg.wf.Exec
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      [f, n2]

    "replace with B": ([flow, mid]) ->
      assert.throws gg.wf.rule.Node.replace(flow, mid, genReplacement("B"))

    "replace with E": ([flow, mid]) ->
      gg.wf.rule.Node.replace(flow, mid, genReplacement("E"))

    "replace with EBE": ([flow, mid]) ->
      gg.wf.rule.Node.replace(flow, mid, genReplacement("EBE"))

  "exec-barrier-exec"
    topic: ->
      n1 = new gg.wf.Exec
      n2 = new gg.wf.Barrier
      n3 = new gg.wf.Exec
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      f.connectBridge n1, n3
      [f, n2]


  "barrier-exec-exec"
    topic: ->
      n1 = new gg.wf.Barrier
      n2 = new gg.wf.Exec
      n3 = new gg.wf.Exec
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      f.connectBridge n2, n3
      [f, n2]



  "exec-exec-barrier"
    topic: ->
      n1 = new gg.wf.Exec
      n2 = new gg.wf.Exec
      n3 = new gg.wf.Barrier
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      f.connectBridge n1, n2
      [f, n2]



  "exec-barrier-barrier"
    topic: ->
      n1 = new gg.wf.Exec
      n2 = new gg.wf.Barrier
      n3 = new gg.wf.Barrier
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      [f, n2]




  "barrier-barrier-exec"
    topic: ->
      n1 = new gg.wf.Barrier
      n2 = new gg.wf.Barrier
      n3 = new gg.wf.Exec
      f = new gg.wf.Flow
      f.connect n1, n2
      f.connect n2, n3
      [f, n2]



