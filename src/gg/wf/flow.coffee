#<< gg/util/*
#<< gg/wf/*
events = require 'events'



#
# TODO: define a nested workflow spec that can be created and consumed
#       it should have hooks to map onto higher level operators (e.g., geom, scale)
#
# This class stores the blueprint for a workflow.  It tracks:
#
# 1) The list of distinct nodes in the flow
# 2) The directed edges between nodes
# 3) Bridging edges that skip barriers
#
# (2) has aliasing problems, because if the following configuration occurs
#     it can't differentiate if a -> b or a -> y
#
#   a -> Barrier -> b
#   x -> Barrier -> y
#
# (3) bridging edges disambiguate the above
#
# The blueprint can be instantiated into a runnable workflow
# by calling flow.instantiate()
#
class gg.wf.Flow extends events.EventEmitter
  @ggpackage = "gg.wf.Flow"
  @id: -> gg.wf.Flow::_id += 1
  _id: 0

  constructor: (@spec={}) ->
    @id = gg.wf.Flow.id()
    @graph = new gg.util.Graph (node)->node.id
    @log = gg.util.Log.logger @constructor.ggpackage, "flow"

    # dynamically instantiated
    # nodes are {n: nodeid, p: port}
    @portGraph = null

    @debug = {}



  instantiate: ->

    # setup node metadata and input slots
    f = (node) =>
      parentWeights = _.map @parents(node), (parent) =>
        @edgeWeight parent, node
      childWeights = _.map @children(node), (child) =>
        @edgeWeight node, child
      nParents = _.sum parentWeights
      nChildren = _.sum childWeights
      node.flow = @
      node.setup nParents, nChildren

    @graph.bfs f

    #
    # Create a graph of (node, outport) -> (node, inport) mappings
    # Uses bridge edges to connect across barriers
    #

    inportsMap = _.o2map @nodes(), (node) -> [node.id, 0]
    outportsMap =_.o2map @nodes(), (node) -> [node.id, 0]
    @portGraph = new gg.util.Graph (o) -> "#{o.n.id}-#{o.p}"
    pstore = gg.prov.PStore.get @

    # add a nonbarrier -> barrier* -> nonbarrier path to the port graph
    connectPath = (path) =>
      from = null
      for to in path
        if from?
          outport = outportsMap[from.id]
          inport = inportsMap[to.id]

          f = {n: from, p: outport}
          t = {n: to, p: inport}
          @portGraph.connect f, t
          pstore.connect f, t

          outportsMap[from.id] += 1
          inportsMap[to.id] += 1

        from = to

    for [from, to, type, weight] in @graph.edges("bridge")
      # find the path of barrier nodes connecting
      # from -> to and allocate port mappings
      path = @findPath from, to
      for weightid in [0...weight]
        connectPath path

    @








  nodes2str: (nodes, sep="  ") ->
    nodes.map((n)->n.name).join(sep)


  toString: ->
    arr = []
    f = (node) =>
        childnames = _.map @children(node), (c) =>
          "#{c.name}(#{@edgeWeight node, c})"
        cns = childnames.join(', ') or "SINK"
        arr.push "#{node.name}@#{node.location}\t->\t#{cns}"
    @graph.bfs f
    arr.join("\n")

  # @return JSON object that encapsulates the workflow graph
  #
  #     id:
  #     spec: ...
  #     graph:
  #       nodes:
  #         [
  #           {
  #             node:    node object
  #             name:    node name
  #             barrier: barrier node?
  #             id:      node.id
  #           }
  #         ]
  #       links:
  #         [
  #           {
  #             source: idx into nodes
  #             target: idx into nodes
  #             weight: edge weight
  #             type:   "normal" | "barrier"
  #
  #           }
  #         ]
  #
  toJSON: () ->
    id2idx = _.list2map @nodes(), (node, idx) -> [node.id, idx]
    node2json = (node) ->
      node.toJSON()
    edge2json = (from, to, type, md) ->
      source: id2idx[from.id]
      target: id2idx[to.id]
      type: type
      weight: md

    {
      id: @id
      graph: @graph.toJSON node2json, edge2json
      spec: _.toJSON @spec
    }



  @fromJSON: (json) ->
    json2edge = (link, nodes) ->
      [
        nodes[link.source]
        nodes[link.target]
        link.type
        link.weight
      ]
    json2node = gg.wf.Node.fromJSON
    graph = gg.util.Graph.fromJSON json.graph, json2node, json2edge
    spec = _.fromJSON json.spec
    flow = new gg.wf.Flow spec
    flow.graph = graph
    flow.id = json.id
    flow

  # this loses the DOM and other self-referential objects in node spec and params
  clone: -> gg.wf.Flow.fromJSON @toJSON()


  # Encode graph as a tree structure
  # @returns data structure of the form
  # {
  #   name:
  #   id:
  #   children: [ ... ] # recursive
  # }
  toJSONTree: ->
    root = {
      name: "root",
      id: -1
      "children": [
      ]
    }
    id2node = {
      "-1": root
    }
    @graph.bfs (node) =>
      id = node.id
      id2node[id] = {
        name: node.name
        id: node.id
        node: node
        "children": [
        ]
      }
      parents = @parents node
      parents = [root] unless parents.length > 0
      _.each parents, (par) =>
        id2node[par.id].children.push id2node[id]
    root

  # Export graph is a DOT formatted string
  toDot: (rankdir='TD') ->
    text = []
    text.push "digraph G {"
    text.push "graph [rankdir=#{rankdir}]"
    _.each @graph.edges(), (edge) =>
      [n1, n2, type, weight] = edge
      color = if type is "normal" then "black" else "green"
      text.push "\"#{n1.name}:#{n1.id}\" -> \"#{n2.name}:#{n2.id}\" [color=\"#{color}\", label=\"#{type}:#{weight}\"];"
    text.push "}"
    text.join("\n")




  #
  # Flow Manipulation
  #

  add: (node) ->
    node.wf = @
    @graph.add node

  # Remove a node and fix up the bridges
  rm: (node) ->
    ps = @parents node
    cs = @children node
    if @parents(node).length > 1
      @log.err @parents(node)
      throw Error("don't support removing multi-parent node #{node.name}")

    if @children(node).length > 1
      @log.err @children(node)
      throw Error("don't support removing multi-child node #{node.name}")


    c = p = null
    if ps.length > 0 
      p = ps[0] 
      md = @edgeWeight p, node, "normal"
    if cs.length > 0
      c = cs[0]
      md = @edgeWeight node, c, "normal"

    if node.isBarrier()
      @graph.rm node
      @connect p, c if p? and c?
    else
      unless p? and c?
        @graph.rm node
      else
        bps = @bridgedParents node
        bcs = @bridgedChildren node
        if bps.length > 1
          throw Error "#{node.name}.bridgeparents  #{bps.length} > 1"
        if bcs.length > 1
          throw Error "#{node.name}.bridgechildren #{bcs.length} > 1"

        bmd = bp = bc = null
        if bps.length > 0
          bp = bps[0] 
          bmd = @edgeWeight bp, node, "bridge"
        if bcs.length > 0
          bc = bcs[0]
          bmd = @edgeWeight node, bc, "bridge"

        @graph.rm node
        @connect p, c, "normal", md if p? and c?
        @connect bp, bc, "bridge", bmd if bp? and bc?


  insertAfter: (node, parent, checkChildren=yes) ->
    if @children(parent).length > 0 and checkChildren
      for child in @children parent
        if child?
          @log "insertAfter calling insert: #{node.name}, #{parent.name}, #{child.name}"
          @insert node, parent, child
      return

    if node.isBarrier() == parent.isBarrier()
      @connect parent, node, 'normal'
      unless node.isBarrier()
        @connect parent, node, 'bridge'
    else
      b2str = (b) -> if b then "barrier" else "nonbarrier"
      throw Error "Can't insert #{b2str node.isBarrier()} 
                   after #{b2str parent.isBarrier()}"

  insertBefore: (node, child, checkParents=yes) ->
    if @parents(child).length > 0 and checkParents
      @log "insertBefore #{child.name} has parents"
      for p in @parents child
        if p?
          @log "insertBefore calling insert: #{node.name}, #{p.name}, #{child.name}"
          @insert node, p, child
      return

    if node.isBarrier() == child.isBarrier()
      @connect node, child, 'normal'
      unless node.isBarrier()
        @connect node, child, 'bridge'
    else
      b2str = (b) -> if b then "barrier" else "nonbarrier"
      throw Error "Can't insert #{b2str node.isBarrier()} 
                   before #{b2str child.isBarrier()}"


  # Insert node between adjacent nodes parent -- child
  # Completely disconnects edges (even if weight > 1)
  insert: (node, parent, child) ->

    unless _.any @children(parent), ((pc) -> pc.id is child.id)
      throw Error("parent not parent of child: #{parent.toString()}\t#{child.toString()}")

    if parent? and not child?
      @insertAfter node, parent, no
      return
    if child? and not parent?
      @insertBefore node, child, no
      return

    if parent.isBarrier() and child.isBarrier()
      if node.isBarrier()
        md = @disconnect parent, child, "normal"
        @connect parent, node, "normal", md
        @connect node, child, "normal", md
      else
        throw Error("Can't insert a nonbarrier between two barriers")

    if parent.isBarrier() and not child.isBarrier()
      if node.isBarrier()
        totalWeight = _.sum @children(parent), (c) => @edgeWeight parent, c
        for bc in @children parent
          md = @disconnect parent, bc, "normal"
          @connect node, bc, "normal", md
        @connect parent, node, "normal", totalWeight
      else
        md = @disconnect parent, child, "normal"
        @connect parent, node, "normal", md
        @connect node, child, "normal", md

        for bp in @bridgedParents child
          md = @disconnect bp, child, "bridge"
          @connect bp, node, "bridge"


    if not parent.isBarrier() and child.isBarrier()
      if node.isBarrier()
        totalWeight = _.sum @parents(child), (p) => @edgeWeight p, child
        for bp in @parents child
          md = @disconnect bp, child, "normal"
          @connect bp, node, "normal", md
        @connect node, child, "normal", totalWeight
      else
        md = @graph.disconnect parent, child, "normal"
        @connect node, child, "normal", md
        @connect parent, node, "normal", md
        
        for bc in @bridgedChildren parent
          md = @disconnect parent, bc, "bridge"
          @connect node, bc, "bridge", md

        @connect parent, node, "bridge", md

    if not parent.isBarrier() and not child.isBarrier()
      if node.isBarrier()
        throw Error("Can't insert a barrier between two non-barriers")
      else
        md = @disconnect parent, child, "normal"
        @connect parent, node, "normal", md
        @connect node, child, "normal", md
        md = @disconnect parent, child, "bridge"
        @connect parent, node, "bridge", md
        @connect node, child, "bridge", md


  findByClass: (klass) ->
    @find (n) -> _.isType n, klass

  findOne: (f) -> @find(f)[0]

  find: (f) ->
    ret = []
    @graph.dfs (node) ->
      if f node
        ret.push node
    ret

  nodeFromId: (id) ->
    nodes = @graph.nodes((node) -> node.id == id)
    if nodes.length then nodes[0] else null

  nodes: -> @graph.nodes()

  edges: (args...) -> @graph.edges(args...)

  connect: (from, to, type="normal", weight=null) ->
    unless weight?
      if @graph.edgeExists from, to, type
        weight = 1 + @graph.metadata(from, to, type)
      else
        weight = 1
    @graph.connect from, to, type, weight
    @log "connected #{from.name} -> #{to.name} type #{type} w #{weight}"
    @

  connectBridge: (from, to) ->
    throw Error("connectBridge: from #{from.name} is barrier") if from.isBarrier()
    throw Error("connectBridge: to #{to.name} is barrier") if to.isBarrier()
    @connect from, to, "bridge"
    @

  # @return metadata of disconnected edge
  disconnect: (from, to, type="normal") ->
    @log "disconnected #{from.name} -> #{to.name} type #{type}  w #{@graph.metadata(from, to, type)}"
    @graph.disconnect from, to, type

  edgeWeight: (from, to, type="normal") ->
    @graph.metadata(from, to, type) or 0

  children: (node) -> @graph.children node, "normal"
  bridgedChildren: (node) -> @graph.children node, "bridge"

  parents: (node) -> @graph.parents node, "normal"
  bridgedParents: (node) -> @graph.parents node, "bridge"

  isAncestor: (anc, desc) ->
    return no if anc == desc
    found = no
    f = (n) ->
      if n == desc
        found = yes

    @graph.dfs f, anc
    found



  # Get node's input ports that are mapped to parent's outputs
  inputPorts: (parent, node) ->
    pids = _.map @parents(node), (p) =>
      weight = @edgeWeight p, node
      _.times weight, () -> p.id
    pids = _.flatten pids
    idxs = []
    _.each pids, (pid, idx) ->
      idxs.push idx if pid == parent.id
    idxs

  # Get node's output ports that map to child
  outputPorts: (node, child=null) ->
    cids = _.map @children(node), (c) =>
      weight = @edgeWeight node, c
      _.times weight, () -> c.id
    cids = _.flatten cids
    idxs = []
    _.each cids, (cid, idx) ->
      idxs.push idx if not child? or cid == child.id
    idxs

  sources: -> @graph.sources()
  sinks: -> @graph.sinks()

  findPath: (from, to) ->
    search = (node, path=[]) =>
      path.push node
      if node.id == to.id
        return path

      for child in @children(node)
        result = search child, path
        return result if result?
      path.pop()
      null
    path = search from
    path



  #
  # Convenience functions for linearly adding nodes to the workflow
  # If you want to use multicast to construct a tree, you will need to do that manually.
  #
  isNode: (specOrNode) -> not (specOrNode.constructor.name is 'Object')
  node: (node) -> @setChild null, node
  exec: (specOrNode) -> @setChild gg.wf.Exec, specOrNode
  split: (specOrNode) -> @setChild gg.wf.Split, specOrNode
  partition: (specOrNode) -> @setChild gg.wf.Partition, specOrNode
  merge: (specOrNode) -> @setChild gg.wf.Merge, specOrNode
  barrier: (specOrNode) -> @setChild gg.wf.Barrier, specOrNode
  multicast: (specOrNode) -> @setChild gg.wf.Multicast, specOrNode
  extend: (nodes) -> _.each _.compact(nodes), (node) => @setChild null, node

  # Add child to end of workflow
  # @param specOrNode specification of a node or a Node object
  setChild: (klass, specOrNode) ->
    specOrNode = {} unless specOrNode?
    if _.isSubclass specOrNode, gg.wf.Node
      node = specOrNode
    else if _.isFunction specOrNode
      node = new klass 
        params:
          compute: specOrNode
    else
      node = new klass specOrNode

    @log "setChild: #{node.name} #{node.id}"

    sinks = @sinks()
    if sinks.length > 1
      throw Error("setChild only works for non-forking flows") 

    prevNode = prevNonBarrierNode = sinks[0] if sinks.length > 0
    if prevNode?
      while prevNonBarrierNode.isBarrier()
        parents = @parents prevNonBarrierNode
        if parents.length != 1
          throw Error("")
        prevNonBarrierNode = parents[0]
      @connect prevNode, node 
      @connectBridge prevNonBarrierNode, node

    @add node
    this

  # add a parent to every existing source
  prepend: (node) ->
    _.each @sources(), (source) =>
      @connect node, source
      @connectBridge node, source


  setupRPC: (runner, uri) ->
    rpc = new gg.wf.RPC
      params:
        uri: uri

    rpc.on "register", (status) =>
      @log "flow registered!"
      runner.run()

    rpc.on "runflow", (nodeid, outport, outputs) =>
      node = @nodeFromId nodeid
      if node?
        @log.warn "runflow result: #{[node.name, nodeid, outport, node.location]}"
      @log outputs
      runner.ch.routeNodeResult nodeid, outport, outputs


    runner.ch.xferControl = (nodeid, outport, outputs) =>
      rpc.run @id, nodeid, outport, outputs

    runner.on "done", () =>
      rpc.deregister @

    rpc.register @

  # Execute this flow on the client side
  run: (graphicOpts) ->
    graphicOpts = new gg.core.Options unless graphicOpts?

    unless _.all(@sources(), (s) -> s.type == 'start')
      start = new gg.wf.Start
      @prepend start

    unless @sources().length == 1
      throw Error()

    @instantiate()

    if @log.level <= gg.util.Log.DEBUG
      json = @portGraph.toJSON null, (fr, to, type, md) ->
        "\t#{fr.n.name}(#{fr.p}) -> #{to.n.name}(#{to.p})"
        
      @log "Flow Graph:"
      @log @toString()
      @log "Port Graph:"
      @log json.links.join("\n")

    runner = new gg.wf.Runner @, null
    runner.on "output", (nodeid, outport, data) =>
      @emit "output", outport, data

    runner.on "done", (debug) =>
      @debug = debug
      @emit "done", debug
    @log "created runner"

    # if can access server
    uri = graphicOpts.serverURI
    onConnect = () => 
      @log.warn "connected to server at #{uri}"
      @setupRPC runner, uri
    onErr = () => 
      @log.warn "error connecting to server at #{uri}"
      runner.run()
    @log "checking rpc connection"
    gg.wf.RPC.checkConnection uri, onConnect, onErr



