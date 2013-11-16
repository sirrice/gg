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

      #
      # expand barrier in both directions to collect longest contiguous path of barriers
      # constraint: all internal nodes in the path must have 1 parent and 1 child
      #
      node = barrier
      while true
        seen[node.id] = yes
        children = flow.children node 
        unless children.length == 1 and children[0].isBarrier()
          break
        child = children[0]
        childparents = flow.parents child
        unless childparents.length == 1
          break
        path.push child
        node = child

      node = barrier
      while true
        seen[node.id] = yes
        parents = flow.parents node
        unless parents.length == 1 and parents[0].isBarrier()
          break
        parent = parents[0]
        parchildren = flow.children parent
        unless parchildren.length == 1
          break
        path.unshift parent
        node = parent

      if path.length > 1
        tomerge.push path

    console.log tomerge

    for path in tomerge
      newnode = @mergeNodes path

      first = path[0]
      last = _.last path
      firstps = flow.parents first
      lastcs = flow.children last

      # disconnect first in path and connect to new node
      if firstps.length > 0
        totalWeight = _.sum firstps, (p) -> flow.edgeWeight p, first
        for p in firstps
          md = flow.disconnect p, first, "normal"
          flow.connect p, newnode, "normal", md

      # disconnect last in path and connect to new node
      if lastcs.length > 0
        totalWeight = _.sum lastcs, (c) -> flow.edgeWeight last, c
        for c in lastcs
          md = flow.disconnect last, c, "normal"
          flow.connect newnode, c, "normal", md



    console.log flow.toDot()
    flow

  mergeNodes: (path) ->
    names = _.map path, (n) -> n.name
    computes = _.map path, (n) -> 
      f = n.params.get "compute"
      f ?= n.compute.bind n
      ((n) ->
        (tableset, cb) -> f tableset, n.params, cb
      )(n)

    f = ((computes) ->
      (tableset, params, finalcb) ->
        computes.unshift (cb) -> cb null, tableset
        
        async.waterfall computes, (err, result) ->
          finalcb null, result
    )(computes)

    new gg.wf.Barrier
      name: "merged-#{names.join('_')}"
      params: 
        compute: f
