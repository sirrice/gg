
# Takes a flow as input and outputs a flow that may have swapped nodes for
# other implementations or subflows for single nodes.
#
class gg.wf.Optimizer
  constructor: (@rules) ->
  optimize: (flow) ->

    return flow
    canRpcify = (node) ->
      not _.any [
        /RPC/.test node.constructor.name
        node.params.get('clientonly')
      ]

    multicasts = flow.graph.nodes (n) -> n.type == 'multicast'
    multicast = multicasts[0]

    # Mark RPC-able nodes as "server"
    nodes = flow.graph.nodes canRpcify
    _.each nodes, (node) ->
      #unless flow.graph.isAncestor node, multicast
      node.location = "server"

    #flows = gg.wf.Optimizer.findSplit flow

    flow

  @findSplit: (flow) ->
    isSame = (n1, n2) ->
      if n1?
        n1.location == n2.location
      else
        true

    search = (prev, prevNonBarrier, cur, prevflow) ->
      # invariant: prevflow contains prev
      if isSame prev, cur
        if prev?
          prevflow.connect prev, cur
        else
          prevflow.add cur

        unless cur.type == 'barrier'
          prevNonBarrier = cur
          if prev?
            prevflow.connectBridge prevNonBarrier, cur
      else
        console.log "not same: #{prev.name}\t#{cur.name}"
        prevflow = new gg.wf.Flow flow.spec
        flows.push prevflow
        prevflow.add cur
        prevNonBarrier = null

      for child in flow.children(cur)
        search cur, prevNonBarrier, child, prevflow

    flows = [new gg.wf.Flow(flow.spec)]
    for source in flow.sources()
      search null, null, source, flows[0]

    _.each flows, (flow, idx) ->
      console.log "flow #{idx}"
      console.log flow.toString()
      console.log


    flows

  @swapForSPC: (flow, nodes) ->
    # swap node for rpcified node
    _.each nodes, (node) ->
      rpc = gg.wf.Optimizer.rpcify node
      cs = flow.children(node)
      bcs = flow.bridgedChildren(node)
      ps = flow.parents(node)
      bps = flow.bridgedParents(node)
      flow.graph.rm node
      flow.add rpc
      _.each cs, (c) -> flow.connect rpc, c
      _.each bcs, (c) -> flow.connectBridge rpc, c
      _.each ps, (p) -> flow.connect p, rpc
      _.each bps, (p) -> flow.connectBridge p, rpc


  @rpcify: (node) ->
    return node if /RPC/.test node.constructor.name
    return node if node.params.get('clientonly')

    klass = if node.type == 'barrier'
      gg.wf.RPCBarrier
    else if _.isSubclass(node, gg.wf.Source)
      gg.wf.RPCSource
    else if _.isSubclass(node, gg.wf.Split)
      gg.wf.RPCSplit
    else if _.isSubclass(node, gg.wf.Merge)
      gg.wf.RPCMerge
    else
      gg.wf.RPC

    rpc = new klass
      name: "rpc-#{node.name}"
      params: node.params

    return rpc

  dynamicrpcify: (node) ->
    # copy:

    # 1. setup input ports
    _.each node.inputs, () -> rpc.addInputPort()

    # 2. add parents and connect the ports
    _.times node.inputs.length, (idx) ->
      # find all parent nodes that write to this port
      parentpairs = _.compact _.map(node.parent2in, (pair, inport) ->
        pair if idx == inport)
      for [pid, poutport] in parentpairs
        parent = _.first _.filter(node.parents, (p) -> p.id == pid)
        parent.addOutputHandler poutport, rpc.getAddInputCB(idx)
        rpc.addParent parent, poutport, idx

    # 4. for each input port, find the connected child ports and the children
    _.each _.keys(node.in2out), (inport) ->
      for outport in node.in2out[inport]
        childport = node.out2child[outport]
        child = node.children[outport]
        childCb = child.getAddInputCB(childport)

        console.log "addoutput #{outport}\t#{child.name}.port(#{childCb.port})"
        rpc.addChild child, childCb
        rpc.connectPorts inport, outport, childport

    # 5. add output listeners
    _.each node.listeners('output'), (l) -> rpc.on 'output', l

    # 6. existing inputs
    rpc.inputs = _.clone node.inputs

    console.log "rpcified node"
    console.log node
    console.log rpc

    return rpc




