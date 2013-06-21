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
class gg.wf.Flow extends gg.wf.Node
  constructor: (@spec={}) ->
    @graph = new gg.util.Graph (node)->node.id
    @g = @spec.g  # graphic object that compiled into this workflow
    @log = gg.util.Log.logger "flow ", gg.util.Log.WARN

    # port/inputs index -> [source node id, source inport]
    @inport2sourceport = {}
    # port -> [child node id, child inport]
    @outport2childport = {}
    # [base sink node id, child inport] -> outport
    @sinkport2outport = {}

    @portGraph = null


  instantiate: ->
    # setup node metadata and input slots
    f = (node) =>
      parentWeights = _.map @parents(node), (parent) =>
        @edgeWeight parent, node
      childWeights = _.map @children(node), (child) =>
        @edgeWeight node, child
      nParents = _.sum parentWeights
      nChildren = _.sum childWeights
      node.setup nParents, nChildren

    @graph.bfs f

    #
    # Explicitly allocate outport to inport mappings between
    # nodes.  Ensure that bridges are correctly connected
    #
    inportsMap = _.o2map @nodes(), (node) -> [node.id, 0]
    outportsMap =_.o2map @nodes(), (node) -> [node.id, 0]
    @portGraph = new gg.util.Graph (o) -> "#{o.n.id}-#{o.p}"
    connectPath = (path) =>
      from = null
      for to in path
        if from?
          outport = outportsMap[from.id]
          inport = inportsMap[to.id]

          f = {n: from, p: outport}
          t = {n: to, p: inport}
          @portGraph.connect f, t

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








  nodes2str: (nodes, sep="  ") ->
    nodes.map((n)->n.name).join(sep)


  toString: ->
    arr = []
    f = (node) =>
        childnames = _.map @children(node), (c) =>
          "#{c.name}(#{@edgeWeight node, c})"
        cns = childnames.join(', ') or "SINK"
        arr.push "#{node.name}\t->\t#{cns}"
    @graph.bfs f
    arr.join("\n")

  toJSON: (type="graph") ->
    switch type
      when "tree" then @toJSONTree()
      else @toJSONGraph()


  # @return JSON object tha encapsulates the workflow graph
  #       list triples: [source, dest, edge type, weight]
  #
  #       edge type: "normal", "bridge"
  #
  toJSONGraph: ->
    json = {}
    nodes = _.map @nodes, (node) ->
      name: node.name
      barrier: _.isSubclass node, gg.wf.Barrier
      id: node.id
      #node: node

    id2idx = _.list2map @nodes, (node, idx) -> [node.id, idx]

    links = []
    _.map @nodes, (node) =>
      norms =  _.map _.uniq(@children(node)), (child) =>
        source: id2idx[node.id]
        target: id2idx[child.id]
        weight: @edgeWeight node, child
        type: "normal"

      bridges = _.map _.uniq(@bridgedChildren(node)), (child) =>
        source: id2idx[node.id]
        target: id2idx[child.id]
        weight: @edgeWeight node, child
        type: "bridge"

      links.push.apply links, norms
      links.push.apply links, bridges

    json.nodes = nodes
    json.links = links
    json

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

  toDot: ->
    text = []
    text.push "digraph G {"
    text.push "graph [rankdir=LR]"
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

  nodes: -> @graph.nodes()

  connect: (from, to, type="normal") ->
    if @graph.edgeExists from, to, type
      weight = 1 + @graph.metadata from, to, type
    else
      weight = 1
    @log "connect #{from.name}\t#{to.name}\t#{type}\t#{weight}"
    @graph.connect from, to, type, weight
    @

  connectBridge: (from, to) ->
    throw Error() if _.isSubclass from, gg.wf.Barrier
    throw Error() if _.isSubclass to, gg.wf.Barrier
    @connect from, to, "bridge"
    @

  edgeWeight: (from, to, type="normal") ->
    @graph.metadata(from, to, type) or 0

  children: (node) -> @graph.children node, "normal"
  bridgedChildren: (node) -> @graph.children node, "bridge"

  parents: (node) -> @graph.parents node, "normal"
  bridgedParents: (node) -> @graph.parents node, "bridge"

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
  extend: (nodes) -> _.each nodes, (node) => @setChild null, node

  # Add child to end of workflow
  # @param specOrNode specification of a node or a Node object
  setChild: (klass, specOrNode) ->
    specOrNode = {} unless specOrNode?
    @log "setChild: #{specOrNode.constructor.name}"
    if _.isSubclass specOrNode, gg.wf.Node
      node = specOrNode
    else if _.isFunction specOrNode
      node = new klass {f: specOrNode}
    else
      node = new klass specOrNode

    sinks = @sinks()
    throw Error("setChild only works for non-forking flows") if sinks.length > 1
    prevNode = null
    prevNode = sinks[0] if sinks.length > 0
    @connect prevNode, node if prevNode?
    @add node
    this


  run: (table) ->
    if table?
      tablesource = new gg.wf.TableSource
        params:
          table: table
      _.each @sources(), (source) =>
        @connect tablesource, source
        @connectBridge tablesource, source

    unless @sources().length == 1
      throw Error()

    @instantiate()

    console.log @toString()

    runner = new gg.wf.Runner @
    runner.on "output", (idx, data) => @emit "output", idx, data
    runner.run()

