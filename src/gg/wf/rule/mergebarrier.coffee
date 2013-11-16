#<< gg/wf/rule/rule

# Merges adjacent barriers 
class gg.wf.rule.MergeBarrier extends gg.wf.rule.Rule
  @ggpackage = "gg.wf.rule.MergeBarrier"

  run: (flow) ->
    console.log "mergebarrier"
    console.log flow.toDot()
    barriers = flow.find (n) -> n.isBarrier()
    seen = {}
    tomerge = []

    for barrier in barriers
      continue if barrier.id of seen

      path = [barrier]
      while true
        seen[barrier.id] = yes
        children = flow.children barrier
        unless children.length == 1 and children[0].isBarrier()
          break
        path.push children[0]
        barrier = children[0]

      if path.length > 1
        tomerge.push path

    console.log tomerge

    for path in tomerge
      names = _.map path, (n) -> n.name
      computes = _.map path, (n) -> 
        f = n.params.get "compute"
        f ?= n.compute.bind n
        ((n) ->
          (tableset, cb) ->
            f tableset, n.params, cb
        )(n)

      f = ((computes) ->
        (tableset, params, finalcb) ->
          computes.unshift (cb) ->
            cb null, tableset
          
          async.waterfall computes, (err, result) ->
            finalcb null, result
      )(computes)

      newnode = new gg.wf.Barrier
        name: "merged-#{names.join('_')}"
        params: 
          compute: f

      flow.insertBefore newnode, path[0]
      for n in path
        flow.rm n

    console.log flow.toDot()
    flow