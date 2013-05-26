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
#
#   a -> Barrier -> b
#   x -> Barrier -> y
#
# (2) can't differentiate if a -> b or a -> y
# (3) bridging edges disambiguate
#
#
#
# The blueprint can be instantiated into a runnable workflow by calling flow.instantiate()
#
class gg.wf.Flow extends events.EventEmitter
  constructor: (@spec={}) ->
    @graph = new gg.util.Graph (node)->node.id
    @g = @spec.g  # graphic object that compiled into this workflow
    @log = gg.util.Log.logger "flow ", gg.util.Log.WARN
    _.extend @constructor.prototype, events.EventEmitter.prototype


  #
  # Create a mutable instance of the workflow that can be sent to a gg.wf.Runner
  #
  # Each node is cloned and their output/input handlers are linked together
  #
  # During execution, the nodes are locally responsible for creating additional
  # duplicates e.g., after Partition operators
  #
  # Details of how nodes are linked:
  #
  # 1) each node has an input handler for each input slot
  # 2) each node calls @emit "output" after running
  #
  # @param node the node to recursively clone.  If null, uses sources()
  #
  # @param barriercache this cache is used to ensure only a single instance of
  #        a barrier is every created
  #
  instantiate: (node=null, barriercache={}) ->
    if node?
      @log "instantitate #{node.name}-#{node.id}\t#{_.isSubclass node, gg.wf.Barrier}"

      if _.isSubclass node, gg.wf.Barrier
        unless node.id of barriercache
          clone = node.clone()
          barriercache[node.id] = clone

        clone = barriercache[node.id]
        cb = clone.addInputPort()
        return [clone, cb]

      else
        clone = node.clone()
        cb = clone.addInputPort()
        endNodes = @bridgedChildren node
        @log "endNodes #{node.name}: [#{endNodes.map((v)->v.name).join("  ")}]"
        @log "children #{node.name}: [#{@children(node).map((v)->v.name).join("  ")}]"

        for child in @children node
          paths = @nonBarrierPaths child, endNodes
          @log "nonBarrierPaths #{node.name}->#{child.name} has #{paths.length} paths"
          for path in paths
            [child, childCb] = @instantiatePath path, barriercache
            outputPort = clone.addChild child, childCb
            clone.connectPorts cb.port, outputPort, childCb.port
            child.addParent clone, outputPort, childCb.port

        [clone, cb]

    else
      sources = @sources()
      root = switch sources.length
        when 0 then throw Error("No sources, cannot instantiate")
        when 1
          if _.isSubclass sources[0], gg.wf.Barrier
            throw Error("Source is a Barrier.  ")
          @instantiate sources[0]
        else
          root = new gg.wf.Multicast
          _.each sources, (source) =>
            [srcclone, srccb] = @instantiate source
            outputPort = root.addChild srcclone, srccb
            srcclone.addParent root, outputPort, srccb.port
          [root, root.getAddInputCB 0]


  #
  #
  # @param path a series of barrier nodes that optionally ends with a non-barrier node
  #        [barrierNode*, [nonBarrierNode]]
  instantiatePath: (path, barriercache) ->
    unless _.every(_.initial(path), ((node) -> _.isSubclass(node, gg.wf.Barrier)))
      throw Error()
    if path.length == 0
      throw Error("instantiatePath: Path length is 0")
    @log "instantiatePath [#{path.map((v)->v.name).join "  "}]"

    first = null
    firstCb = null
    prev = null
    prevCb = null
    for node in path
      [clone, cloneCb] = @instantiate node, barriercache

      if prev?
        outputPort = prev.addChild clone, cloneCb
        prev.connectPorts prevCb.port, outputPort, cloneCb.port
        clone.addParent prev, outputPort, cloneCb.port

      [prev, prevCb] = [clone, cloneCb]
      [first, firstCb] = [clone, cloneCb] unless first?

    [first, firstCb]


  nonBarrierPaths: (node, endNodes, curPath=null, seen=null, paths=null) ->
    curPath = [] unless curPath?
    seen = {} unless seen?
    paths = [] unless paths?

    if node in endNodes
      newPath = _.clone curPath
      newPath.push node
      paths.push newPath if newPath.length > 0
      #@log "nonBarrierPaths add: [#{newPath.map((v) -> v.name).join("  ")}]"
    else if _.isSubclass node, gg.wf.Barrier
      curPath.push node
      children = _.uniq @children node
      #@log "nonBarrierPaths children: #{children.map((v)->"#{v.name}-#{v.id}").join "  "}"
      for child in children
        #@log "nonBarrierPaths barrier #{child.name} has weight: #{@edgeWeight(node, child)}"
        @nonBarrierPaths child, endNodes, curPath, seen, paths
      curPath.pop()
    else
      #@log "nonBarrierPaths skip: #{node.name}"

    paths





  toString: ->
    arr = []
    f = (node) =>
        childnames = _.map @children(node), (c) -> c.name
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






  add: (node) ->
    node.wf = @
    @graph.add node

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

  sources: -> @graph.sources()
  sinks: -> @graph.sinks()


  # Convenience functions for linearly adding nodes to the workflow
  # If you want to use multicast to construct a tree, you will need to do that manually.
  isNode: (specOrNode) -> not (specOrNode.constructor.name is 'Object')
  node: (node) -> @setChild null, node
  exec: (specOrNode) -> @setChild gg.wf.Exec, specOrNode
  split: (specOrNode) -> @setChild gg.wf.Split, specOrNode
  partition: (specOrNode) -> @setChild gg.wf.Partition, specOrNode
  join: (specOrNode) -> @setChild gg.wf.Join, specOrNode
  barrier: (specOrNode) -> @setChild gg.wf.Barrier, specOrNode
  multicast: (specOrNode) -> @setChild gg.wf.Multicast, specOrNode
  extend: (nodes) -> _.each nodes, (node) => @setChild null, node

  # @param specOrNode specification of a node or a Node object
  # WARNING: sets @children to specOrNode (clobbers existing children array)!
  setChild: (klass, specOrNode) ->
    specOrNode = {} unless specOrNode?
    if _.isSubclass specOrNode, gg.wf.Node
      node = specOrNode
    else if _.isFunction specOrNode
      node = new klass {f: specOrNode}
    else
      node = new klass specOrNode

    sinks = @sinks()
    throw Error("setChild only works for non-forking flows") if sinks.length > 1
    prevNode = if sinks.length > 0 then sinks[0] else null
    @connect prevNode, node if prevNode?
    @add node
    this


  run: (table) ->
    [root, rootcb] = @instantiate()
    if table?
      source = new gg.wf.TableSource {wf: @, table: table}
      outputPort = source.addChild root, rootcb
      root.addParent source, outputPort, rootcb.port
      root = source

    runner = new gg.wf.Runner root
    runner.on "output", (id, data) => @emit "output", id, data
    runner.run()


#_.extend gg.wf.Flow.prototype, events.EventEmitter

