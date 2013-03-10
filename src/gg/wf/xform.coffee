#<< gg/util
events = require 'events'

#
# When a node starts running, it is either a Split or not a Split node.
#
# If it is a split node, it needs to
#
# 1. Decide the number of duplicates of its child node
# 2. Instantiate duplicates of the child nodes and establish connections with them
# 3. Execute
# 4. Emit to the proper outputs
#
# Otherwise, it simply needs to execute, and route outputs to the right handlers.
#
# ### Connections:
#
# ::Inputs::
#
# Each node takes as input a single table (except JOIN and Barrier).  They expose a setInput
# method that sets the input slot.
#
#   node.setInput
#
# Join and Barrier must track how many inputs they need to run.
# The number of inputs is defined by the number of times they are duplicated
#
# When clone() is called, a normal Node should:
#
# 1. Make a copy of itself (same spec/initial configuration. Doesn't include child nodes)
# 2. Return the copy and the copy's setInput handler
#
# When clone() is called, Join should:
#
# 1. Check if it's a stopping point.  If yes
#       1. Allocate a new input slot
#       2. Return itself, and the input slot's handler
#    Otherwise
#       1. Copy itself
#       2. Return copy, and the copy's single input slot handler
#
# When clone() is called, Barrier should:
#
# 1. Allocate a new input slot
# 2. Get a copy of it's child
# 3. Hook the child's input handler to the i'th output
# 4. Return self, and the new input slot's handler
#
#
# CloneSubplan() is identical to Clone(), but also
#
# 1. clones the children
# 2. hooks up the clone's output handlers to the children's input handlers
# 3. Returns clone and clone's input handler
#
#
#
# In the future we may have Virtual Nodes, one for each multi-input node so that every
# node has a single setInput method.
#
#
# ::Outputs::
#
# Each node (except Split/Barrier/Multicast) outputs a single table, passed as (id, table).
# The results are passed through an event handler:
#
#   node.emit "output", id, table
#
# Multi-output nodes (Split, Barrirer, Multicast) need to let children register
# for particular outputs.  The idx'th output is passed through:
#
#   node.emit "#{idx}", id, table
#
# It's externally confusing which "output-idx" to bind to.  Thus, the convention is
# for the i'th child in the node.children array to bind to "output-i".  This binding should be
# handled within the addChild method.
#
#

#
# Implements a generic one-input one-output processing node that doesn't run
#
#
# ::Specification::
#
# {
#   type: [exec, split, join, barrier, multicast]
#   f:    {Function}
#   name: {String?}
# }
#
#
class gg.wf.Node extends events.EventEmitter
    constructor: (@spec={}) ->
        # at least one output is expected per child
        @children = [null]

        # a slot, filled with null, should be allocated for every expected input
        @inputs = [null]

        # workflow node belongs to
        # the workflow keeps track of execution state.
        @wf = @spec.wf or null

        @id = gg.wf.Node.id()
        @type = "node"
        @name = findGood [@spec.name, "node-#{@id}"]

    @id: -> gg.wf.Node::_id += 1
    _id: 0

    nChildren: -> _.compact(@children).length
    hasChildren: -> @nChildren() > 0

    # @return {[gg.wf.Node, Function]} where
    # - clone is a new copy of current node,
    # - f() is the input handler associated with the node
    #
    clone: (stop) -> throw Error("gg.wf.Node.clone not implemented")


    # @return {[gg.wf.Node, Function]}
    cloneSubplan: (stop=null) ->
        [copy, addInputCB] = @clone(stop)

        if @children[0]?
            [child, childInputCB] = @children[0].cloneSubplan stop
            copy.addChild child, childInputCB

        [copy, addInputCB]


    #
    # @return {Function}
    # Function that takes array pair [node.id, table] as input and
    # sets the appropriate input slot
    getAddInputCB: (idx) ->
        throw Error("input index #{idx} >= #{@inputs.length}") if idx >= @inputs.length

        (id, data) =>
            if @inputs[idx]?
                throw Error("trying to add input to filled slot #{idx}")
            else
                @inputs[idx] = data

    addInput: (idx, id, data) -> @getAddInputCB(idx)(id, data)

    ready: -> _.all @inputs, (val) -> val?

    # @param {Int} outidx The index of the child the output should be routed to
    # Set an output handler.  Checks to make sure the index is valid
    addOutputHandler: (outidx, cb) ->
        @on outidx, cb if outidx >= 0 and outidx < @children.length

    output: (outidx, id, data) ->
        @emit outidx, id, data
        @emit "output", id, data

    addChild: (node, inputCb=null) ->
        if @children[0]?
            throw Error("Single Output node already has a child")
        @children[0] = node
        @addOutputHandler 0, inputCb if inputCb?




    #
    # The calling function is responsible for calling ready
    # run() will check if node is ready, but will throw an Error if so
    #
    #
    #
    run: -> throw Error("gg.wf.Node.run not implemented")


    walk: (f, seen=null) ->
        seen = {} unless seen?
        seen[@id] = yes

        f @

        for child in _.compact(@children)
            child.walk f, seen if child?



#
class gg.wf.Exec extends gg.wf.Node
    constructor: (@spec={}) ->
        super @spec

        @compute = @spec.f or (table) -> table
        @type = "exec"
        @name = findGood [@spec.name, "exec-#{@id}"]



    # @param {Node} stop nodefactory object to stop cloning at
    clone: (stop=null)->
        clone = new gg.wf.Exec @spec
        [clone, clone.getAddInputCB 0]

    # @return emits to "output-child.id"
    run: ->
        throw Error("node not ready") unless @ready()
        input = @inputs[0]

        output = @compute input
        @output 0, @id, output
        output



#
# @compute(tables) -> tables
# The compute function takes a list of N tables and outputs N tables
# such that the positions of the input and output tables match up
#
class gg.wf.Barrier extends gg.wf.Node
    constructor: (@spec={}) ->
        super @spec

        @compute = @spec.f or (tables) -> tables
        @type = "barrier"
        @name = findGood [@spec.name, "barrier-#{@id}"]


    clone: (stop) ->
        clone = new gg.wf.Barrier @spec
        [clone, clone.getAddInputCB 0]

    cloneSubplan: (stop) ->
        idx = @inputs.length
        @inputs.push null

        # we know that clone == this, so we use @ as shorthand
        if @children[0]?
            [child, childInputCB] = @children[0].cloneSubplan stop
            @addChild child, childInputCB
            if @inputs.length != @children.length
                throw Error("# inputs not same as # children (#{@inputs.length}!=#{@children.length}")

        [this, @getAddInputCB idx]

    getAddInputCB: (idx) ->
        throw Error("input slot #{idx} doesn't exist #{@inputs.length}") if idx >= @inputs.length
        (id, data) =>
            if @inputs[idx]?
                throw Error("Input slot #{idx} already full")
            else
                @inputs[idx] =
                    id: id
                    data: data

    addChild: (child, inputCb=null) ->
        @children.push child
        @addOutputHandler @children.length-1, inputCb if inputCb?

    run: ->
        throw Error("Node not ready") unless @ready()
        datas = _.pluck @inputs, 'data'
        outputs = @compute datas
        for output, idx in outputs
            @output idx, @id, output
        outputs



class gg.wf.Split extends gg.wf.Node
    constructor: (@spec={}) ->
        super @spec

        # TODO: support groupby functions that return an
        # array of keys.
        @gbfunc = @spec.f or () -> 1
        @type = "split"
        @name = findGood [@spec.name, "split-#{@id}"]
        @gbkeyName = findGood [@spec.key, @name]

    clone: (stop) ->
        clone = new gg.wf.Split @spec
        [clone, clone.getAddInputCB 0]

    findMatchingJoin: ->
        ptr = @children[0]
        n = 1
        while ptr?
            n += 1 if ptr.type is 'split'
            n -= 1 if ptr.type is 'join'
            break if n == 0
            ptr = if ptr.hasChildren() then ptr.children[0] else null
        ptr

    split: (n) ->
        if @hasChildren()
            stop = @findMatchingJoin()
            #console.log "\tsplit\t#{@children[0].name}"
            while @children.length < n
                idx = @children.length
                [child, childInputCB] = @children[0].cloneSubplan stop
                @addChild child, childInputCB

    addChild: (child, inputCb=null) ->
        if @children[0]?
            @children.push child
            @addOutputHandler @children.length-1, inputCb if inputCb?
        else
            @children[0] = child
            @addOutputHandler 0, inputCb if inputCb?

    run: ->
        throw Error("Split not ready, expects #{@inputs.length} inputs") unless @ready()
        input = @inputs[0]
        groups = input.split @gbfunc
        numDuplicates = _.size groups

        # TODO: parameterize MAXGROUPS threshold
        if numDuplicates > 1000
            throw Error("I don't want to support more than 1000 groups!")

        @split numDuplicates
        idx = 0
        _.each groups, (subtable, key) =>
            newcol = _.times subtable.nrows(), ()->key
            subtable.addColumn @gbkeyName, newcol
            @output idx, @id, subtable
            idx += 1
        groups


#
# Does not compute anything
class gg.wf.Join extends gg.wf.Node
    constructor: (@spec={}) ->
        super @spec

        @type = "join"
        @name = findGood [@spec.name, "join-#{@id}"]

    clone: (stop) ->
        clone = new gg.wf.Join @spec
        [clone, clone.getAddInputCB 0]

    cloneSubplan: (stop) ->
        if @ is stop
            @inputs.push null
            addInputCB = @getAddInputCB @inputs.length-1
            [@, addInputCB]
        else
            super stop

    ready: ->
        #console.log "#{@name} ready?: #{super()}\t#{@inputs}"
        super

    run: ->
        output = gg.Table.merge _.values(@inputs)
        @output 0, @id, output
        output


# this is the only Node type that has multiple children
# Does not compute anything
class gg.wf.Multicast extends gg.wf.Node
    constructor: (@spec={}) ->
        super @spec

        @type = "multicast"
        @name = findGood [@spec.name, "multicast-#{@id}"]

    clone: (stop) ->
        clone = new gg.wf.Multicast @spec
        [clone, clone.getAddInputCB 0]

    cloneSubplan: (stop) ->
        [clone, addInputCB] = @clone(stop)

        for child, idx in _.compact @children
            [childCopy, childInputCB]  = child.cloneSubplan stop
            clone.addChild childCopy, childInputCB

        [clone, addInputCB]

    addChild: (node, inputCb=null) ->
        unless @children[0]?
            @children[0] = node
        else
            @children.push node
        @addOutputHandler @children.length-1, inputCb if inputCb?

    run: ->
        throw Error("Node not ready") unless @ready()

        input = @inputs[0]
        for child, idx in @children
            @output idx, @id, input
        input


class gg.wf.Composite extends gg.wf.Node

    constructor: (@spec={}) ->
        super @spec

        @nodes = @spec.nodes
        @type = "composite"
        @name = findGood [@spec.name, "comp-#{@id}"]

    clone: (stop) ->
        nodes = []

