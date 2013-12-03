#<< gg/wf/rule/rule

# Merges adjacent execs
class gg.wf.rule.MergeExec extends gg.wf.rule.Rule
  @ggpackage = "gg.wf.rule.MergeExec"

  run: (flow) ->
    getKeys = (n) -> n.params.get 'keys'
    isExec = (n) -> _.isType n, gg.wf.Exec
    isEqual = (k1, k2) -> 
      unless k1? and k2?
        return no if k1?
        return no if k2?
      (_.intersection(k1, k2).length == k1.length and
       k1.length == k2.length)

    execs = flow.find isExec
    seen = {}
    tomerge = []

    for exec in execs
      continue if exec.id of seen
      path = [exec]

      #
      # expand exec in both directions to collect longest contiguous path of execs
      # that share the same keys
      #
      # constraint: all internal nodes in the path must have 1 parent and 1 child
      #
      node = exec
      while true
        seen[node.id] = yes
        children = flow.children node 
        unless children.length == 1 and isExec(children[0])
          break

        child = children[0]
        unless isEqual getKeys(node), getKeys(child)
          @log "keys of #{node.name} vs #{child.name} not the same #{getKeys node} vs #{getKeys child}"
          break
        path.push child
        node = child

      node = exec
      while true
        seen[node.id] = yes
        parents = flow.parents node
        unless parents.length == 1 and isExec(parents[0])
          break

        parent = parents[0]
        unless isEqual getKeys(node), getKeys(parent)
          @log "keys of #{node.name} vs #{parent.name} not the same #{getKeys node} vs #{getKeys parent}"
          break
        path.unshift parent
        node = parent

      if path.length > 1
        tomerge.push path

    @log tomerge

    for path in tomerge
      newnode = @mergeNodes path

      first = path[0]
      last = _.last path
      firstbps = flow.bridgedParents first
      firstps = flow.parents first
      lastbcs = flow.bridgedChildren last
      lastcs = flow.children last

      # disconnect first in path and connect to new node
      if firstps.length > 0
        for p in firstps
          md = flow.disconnect p, first, "normal"
          flow.connect p, newnode, "normal", md

      if firstbps.length > 0
        for bp in firstbps
          md = flow.disconnect bp, first, "bridge"
          flow.connect bp, newnode, 'bridge', md

      # disconnect last in path and connect to new node
      if lastcs.length > 0
        for c in lastcs
          md = flow.disconnect last, c, "normal"
          flow.connect newnode, c, "normal", md

      if lastbcs.length > 0
        for bc in lastbcs
          md = flow.disconnect last, bc, "bridge"
          flow.connect newnode, bc, "bridge", md

      _.each(path, flow.graph.rm.bind(flow.graph))

    @log flow.toDot()
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
        _computes = _.clone computes
        _computes.unshift (cb) -> cb null, tableset
        
        async.waterfall _computes, (err, result) ->
          finalcb null, result
    )(computes)

    new gg.wf.Exec
      name: "merged-#{names.join('_')}"
      params: 
        keys: path[0].params.get('keys')
        compute: f
