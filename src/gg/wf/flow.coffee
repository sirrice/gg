#<< gg/util/*
#<< gg/wf/node
#<< gg/wf/debug
#<< gg/wf/label
events = require 'events'


#
# [
#   a, b, c
# ]
#

#
# A flow is a static workflow before it sees any data
# It tracks node to node relationships, but have not instantiated any input/output handlers
#
# flow.instantiate() will create a mutable instance of the workflow with the
# where one instance of each node in the flow is created by calling clone() and their
# output/inputs are linked together.
#
# Nodes are locally responsible for creating additional duplicates.
#
##### Execution
#
# 1. A job pool is necessary when executing the workflow instance, so that the
#    system doesn't generate too many threads.
# 2. An alternative is for each node to be locally responsible for spawning at most
#    X threads, and bundling groups of child nodes together to run synchronously
#
# :: Events ::
#
# # triggers an "output" event whenever a sink generates results
# @emit "output", id, result
#

class gg.wf.Flow extends events.EventEmitter
  constructor: (@spec={}) ->
    @nodes = []
    @id2node = []
    @inId2outId = {}  # parent -> child edges
    @outId2inId = {}  # child -> parent edges
    @edgeWeights = {} # [parentid, childid] -> count
    @g = @spec.g  # graphic object that compiled into this workflow

  add: (node) ->
    unless node.id of @id2node
      console.log("Caution: node already has a workflow") if node.wf?
      node.wf = @
      @nodes.push node
      @id2node[node.id] = node
      @inId2outId[node.id] = []
      @outId2inId[node.id] = []
    @

  connect: (from, to) ->
    @add(from) unless from.id of @id2node
    @add(to) unless to.id of @id2node

    @inId2outId[from.id].push to.id
    @outId2inId[to.id].push from.id
    edge = JSON.stringify [from.id, to.id]
    @edgeWeights[edge] = 0 unless edge of @edgeWeights
    @edgeWeights[edge] += 1
    console.log "connect #{from.name}\t#{to.name}"

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

  parents: (node) ->
    _.compact(_.flatten [@id2node[id] for id in (@outId2inId[node.id] or [])])


  #
  # Create an instance of the workflow
  #
  instantiate: (node=null, barriercache={}) ->
    if node?

      if node.id of barriercache
        [clone, idx] = barriercache[node.id]
        barriercache[node.id] = [clone, idx+1]
        console.log "#{node.name}-#{node.id}\tcache hit! port #{idx+1}"
        return [clone, clone.getAddInputCB idx+1]

      [clone, cb] = node.clone()

      for child in @children node
        for i in _.range @edgeWeight(node,child)
          console.log "instantiate child: #{node.name}-#{node.id}\t#{child.name}-#{child.id}\t#{_.isSubclass node, gg.wf.Barrier}"
          [childclone, childcb] = @instantiate child, barriercache
          clone.addChild childclone, childcb

      if _.isSubclass node, gg.wf.Barrier
        console.log "caching clone of #{node.name}-#{node.id}"
        barriercache[node.id] = [clone, 0]

      [clone, cb]

    else
      sources = @sources()
      root = switch sources.length
        when 0 then throw Error("not sources, cannot instantiate")
        when 1 then @instantiate sources[0]
        else
          root = new gg.wf.Multicast
          _.each sources, (source) =>
            [srcclone, srccb] = @instantiate source, barriercache
            root.addChild srcclone, srccb
          [root, root.getAddInputCB 0]

  run: (table) ->
    [root, rootcb] = @instantiate()
    if table?
      source = new gg.wf.TableSource {wf: @, table: table}
      source.addChild root, rootcb
      root = source

    runner = new gg.wf.Runner root
    runner.on "output", (id, data) => @emit "output", id, data
    runner.run()

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

  isNode: (specOrNode) -> not (specOrNode.constructor.name is 'Object')
  node: (node) -> @setChild null, node
  exec: (specOrNode) -> @setChild gg.wf.Exec, specOrNode
  split: (specOrNode) -> @setChild gg.wf.Split, specOrNode
  partition: (specOrNode) -> @setChild gg.wf.Partition, specOrNode
  join: (specOrNode) -> @setChild gg.wf.Join, specOrNode
  barrier: (specOrNode) -> @setChild gg.wf.Barrier, specOrNode
  multicast: (specOrNode) -> @setChild gg.wf.Multicast, specOrNode
  extend: (nodes) -> _.each nodes, (node) => @setChild null, node



#
# potentially transformation rules
#
class gg.wf.Rule
    constructor: ->



# Takes a flow as input and outputs a flow that may have swapped nodes for
# other implementations or subflows for single nodes.
#
class gg.wf.Optimizer
    constructor: (@rules) ->
    optimize: (flow) -> flow



class gg.wf.Runner extends events.EventEmitter
  constructor: (@root) ->

  run: () ->
    queue = new gg.util.UniqQueue [@root]

    seen = {}
    results = []
    nprocessed = 0
    firstUnready = null

    until queue.empty()
      cur = queue.pop()
      continue unless cur?
      continue if cur.id of seen


      console.log "run #{cur.name} id:#{cur.id} with #{cur.nChildren()} children"
      if cur.ready()
        nprocessed += 1

        unless cur.nChildren()
          # cur is a sink, register output handler for it
          cur.addOutputHandler 0, (id, result) =>
            @emit "output", id, result.table

        cur.run()
        seen[cur.id] = yes

        for nextNode in _.compact(_.flatten cur.children)
          queue.push nextNode unless nextNode of seen
      else
        filled = _.map cur.inputs, (v) -> v?
        console.log "not ready #{cur.name} id: #{cur.id}.  #{cur.inputs.length}, #{cur.children.length}"
        if firstUnready is cur
          if nprocessed == 0
            console.log "#{cur.name} inputs buffer: #{cur.inputs.length}"
            console.log "#{cur.name} ninputs filled: #{filled}"
            console.log "#{cur.name} parents: #{_.map(cur.parents, (p)->p.name).join(',')}"
            console.log "#{cur.name} children: #{_.map(cur.children, (p)->p.name).join(',')}"

            throw Error("could not make progress.  Stopping on #{cur.name}")
          else
            firstUnready = null

        unless firstUnready?
            firstUnready = cur
            nprocessed = 0
        queue.push cur

    @emit "done", yes


