#<< gg/util
#<< gg/wf/xform
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
    constructor: (@spec) ->
        @nodes = []
        @id2node = []
        @inId2outId = {}  # parent -> child edges
        @outId2inId = {}  # child -> parent edges

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
        console.log "connect #{from.name}\t#{to.name}"

        @

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


    instantiate: (node=null) ->
        if node?
            clone = node.clone()[0]
            for child in @children(node)
                childclone = @instantiate child
                clone.addChild childclone, childclone.getAddInputCB(0)
            clone
        else
            sources = @sources()
            root = switch sources.length
                when 0 then throw Error("not sources, cannot instantiate")
                when 1 then @instantiate sources[0]
                else
                    root = new gg.wf.Multicast
                    _.each sources, (source) =>
                        sourceclone = @instantiate source
                        root.addChild sourceclone, sourceclone.getAddInputCB(0)
                    root

    run: (table) ->
        runner = new gg.wf.Runner @instantiate()
        runner.on "output", (id, table) => @emit "output", id, table
        runner.run(table)

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
        if _.isFunction specOrNode
            node = new klass {f: specOrNode}
        else if specOrNode.constructor.name is not "Object" and specOrNode.type?
            node = specOrNode
        else
            node = new klass specOrNode

        prevNode = _.last(@nodes) or null
        @connect prevNode, node if prevNode?
        @add node
        this

    isNode: (specOrNode) -> not (specOrNode.constructor.name is 'Object')
    exec: (specOrNode) -> @setChild gg.wf.Exec, specOrNode
    split: (specOrNode) -> @setChild gg.wf.Split, specOrNode
    join: (specOrNode) -> @setChild gg.wf.Join, specOrNode
    barrier: (specOrNode) -> @setChild gg.wf.Barrier, specOrNode
    multicast: (specOrNode) -> @setChild gg.wf.Multicast, specOrNode
    extend: (nodes) -> _.each nodes, (node) => @setChild null, node



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

    run: (table) ->
        @root.addInput 0, -1, table
        queue = new gg.UniqQueue [@root]

        seen = {}
        results = []
        nprocessed = 0
        firstUnready = null

        until queue.empty()
            cur = queue.pop()
            unless cur?
                continue
            if cur.id of seen
                console.log "skipping #{cur.name}"
                continue


            console.log "run #{cur.name}-#{cur.id} with #{cur.children.length} children"
            if cur.ready()
                nprocessed += 1

                unless cur.nChildren()
                    # cur is a sink, register output handler for it
                    cur.addOutputHandler 0, (id, result) =>
                        @emit "output", id, result

                cur.run()
                seen[cur.id] = yes

                for nextNode in _.compact(_.flatten cur.children)
                    queue.push nextNode unless nextNode of seen
            else
                console.log "not ready #{cur.name}.  #{cur.inputs}"
                if firstUnready is cur
                    throw Error("could not make progress.  Stopping on #{cur.name}")
                unless firstUnready?
                    firstUnready = cur
                    nprocessed = 0
                queue.push cur

        @emit "done", yes


