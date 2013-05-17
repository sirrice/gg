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
    @nodes = []
    @id2node = []
    @inId2outId = {}  # parent -> child edges
    @outId2inId = {}  # child -> parent edges
    @edgeWeights = {} # [parentid, childid] -> count
    @bridges = {}     # nonbarrier -> nonbarrier (skips the barrier nodes)
    @g = @spec.g  # graphic object that compiled into this workflow

    @log = gg.util.Log.logger "flow", gg.util.Log.DEBUG

  add: (node) ->
    unless node.id of @id2node
      @log.warn "Caution: node already has a workflow" if node.wf?
      node.wf = @
      @nodes.push node
      @id2node[node.id] = node
      @inId2outId[node.id] = []
      @outId2inId[node.id] = []
      @bridges[node.id] = []
    @

  connect: (from, to) ->
    @add(from) unless from.id of @id2node
    @add(to) unless to.id of @id2node

    @inId2outId[from.id].push to.id
    @outId2inId[to.id].push from.id
    edge = JSON.stringify [from.id, to.id]
    @edgeWeights[edge] = 0 unless edge of @edgeWeights
    @edgeWeights[edge] += 1
    @log "connect #{from.name}\t#{to.name}"

    @

  connectBridge: (from, to) ->
    throw Error() if _.isSubclass from, gg.wf.Barrier
    throw Error() if _.isSubclass to, gg.wf.Barrier

    @bridges[from.id].push to.id
    @log "bridge #{from.name}\t#{to.name}"

    @


  edgeWeight: (from, to) ->
    edge = JSON.stringify [from.id, to.id]
    @edgeWeights[edge] or 0

  sources: () ->
    _.filter @nodes, (node) =>
        node.id not of @outId2inId or _.size(@outId2inId[node.id]) == 0

  sinks: ->
    _.filter @nodes, (node) =>
        node.id not of @inId2outId or _.size(@inId2outId[node.id]) == 0

  children: (node) ->
    _.compact(_.flatten [@id2node[id] for id in (@inId2outId[node.id] or [])])

  bridgedChildren: (node) ->
    _.compact(_.flatten [@id2node[id] for id in (@bridges[node.id] or [])])

  parents: (node) ->
    _.compact(_.flatten [@id2node[id] for id in (@outId2inId[node.id] or [])])


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
      @log "instantitate #{node.name}-#{node.id}"

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
        endNodes = @bridgedChildren(node)
        @log "endNodes #{node.name}: [#{endNodes.map((v)->v.name).join("  ")}]"

        for child in @children node
          @log "nonBarrierPaths called on #{child.name}"
          paths = @nonBarrierPaths child, endNodes
          @log "nonBarrierPaths #{node.name}->#{child.name} has #{paths.length} paths"
          for path in paths
            [child, childCb] = @instantiatePath path, barriercache
            outputPortId = clone.addChild child, childCb
            clone.connectPorts cb.port, outputPortId
            child.addParent clone, childCb.port

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
            root.addChild srcclone, srccb
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
        outputPortId = prev.addChild clone, cloneCb
        prev.connectPorts prevCb.port, outputPortId
        clone.addParent prev, cloneCb.port

      [prev, prevCb] = [clone, cloneCb]
      [first, firstCb] = [clone, cloneCb] unless first?

    [first, firstCb]


  nonBarrierPaths: (node, endNodes, curPath=null, seen=null, paths=null) ->
    curPath = [] unless curPath?
    seen = {} unless seen?
    paths = [] unless paths?

    if _.isSubclass node, gg.wf.Barrier
      curPath.push node
      children = _.uniq @children node
      @log "nonBarrierPaths children: #{children.map((v)->"#{v.name}-#{v.id}").join "  "}"
      for child in children
        #@log "nonBarrierPaths barrier #{child.name} has weight: #{@edgeWeight(node, child)}"
        @nonBarrierPaths child, endNodes, curPath, seen, paths
      curPath.pop()
    else if node in endNodes
      newPath = _.clone curPath
      newPath.push node
      paths.push newPath if newPath.length > 0
      @log "nonBarrierPaths add: [#{newPath.map((v) -> v.name).join("  ")}]"
    else
      @log "nonBarrierPaths skip: #{node.name}"

    paths




  #
  # Visit nodes breadth first
  #
  visitBFS: (f) ->
    queue = @sources()
    seen = {}
    while _.size queue
      node = queue.shift()
      continue if node.id of seen

      seen[node.id] = yes
      f node

      _.each @children(node), (child) ->
        queue.push child if child? and child.id not of seen

  #
  # Visit nodes depth first
  #
  visitDFS: (f, node=null, seen=null) ->
    seen = {} unless seen?

    if node?
        return if node.id of seen
        seen[node.id] = yes
        f node

        _.each @children(node), (child) =>
            @visitDFS f, child, seen
    else
        _.each @sources(), (child) =>
            @visitDFS f, child, seen

  toString: ->
    arr = []
    f = (node) =>
        childnames = _.map @children(node), (c) -> c.name
        cns = childnames.join(', ') or "SINK"
        arr.push "#{node.name}\t->\t#{cns}"
    @visitBFS f
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
    @visitBFS (node) =>
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

    prevNode = _.last(@nodes) or null
    @connect prevNode, node if prevNode?
    @add node
    this

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


  run: (table) ->
    [root, rootcb] = @instantiate()
    if table?
      source = new gg.wf.TableSource {wf: @, table: table}
      source.addChild root, rootcb
      root = source

    runner = new gg.wf.Runner root
    runner.on "output", (id, data) => @emit "output", id, data
    runner.run()




