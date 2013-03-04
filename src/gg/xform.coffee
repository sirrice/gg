#<< gg/util
events = require 'events'

# Node execution should be stateless.
#

# by default, blindly clone
class gg.Node extends events.EventEmitter
    constructor: () ->
        # NOTE: all children are instances of the same type.
        @type = "node"
        @children = []
        @input = null
        @nclones = 0
        id = gg.wf.Node.id()


    @id: -> gg.wf.Node::_id += 1
    _id: 0

    toSpec: ->
        {
            type: @type
            children: @children
        }

    @fromSpec: (spec) ->
        new {
            node: gg.wf.Node

        }

    # @param prev previous node instance
    # @param stop nodefactory object to stop cloning at
    clone: (prev, stop=null)->
        return @ if @ == stop

        # XXX: figure this out
        copy = gg.wf.Node.fromSpec @toSpec()

        if @children.length > 0
            child = @children[0].clone(copy, stop)
            copy.children.push child
            @on "output-#{child.id}", child.addInput
            # other setup
        copy

    addInput: ([id, data]) ->
        @input = data
        @run()


    # @return emits to "output-child.id"
    run: ->
        output = @compute @input
        @emit("output-#{child.id}", [@id, output])

    compute: (input) ->
        input



    ############
    # Chaining methods
    ############

    #
    # @param specOrNode specification of a node or a Node object
    # WARNING: sets @children to specOrNode (clobbers existing children array)!
    setChild: (klass, specOrNode) ->
        if @isNode specOrNode
            node = specOrNode
        else
            node = klass.fromSpec specOrNode
        @children = [node]
        node

    exec: (specOrNode) -> @setChild gg.wf.Node, specOrNode
    split: (specOrNode) -> @setChild gg.wf.Split, specOrNode
    join: (specOrNode) -> @setChild gg.wf.Join, specOrNode
    barrier: (specOrNode) -> @setChild gg.wf.Barrier, specOrNode


class gg.Barrier extends gg.Node
    constructor: ->
        super
        @nclones = 1
        @nodeId2cloneId = {}
        @prev2next = {}

    clone: (prev, stop) ->
        @nclones += 1
        @nodeId2cloneId[prev.id] = @nclones

        if @children.length > 0
            child = @children[0].clone(prev, stop)
            @children.push child
            @on "output-#{child.id}", child.addInput
            @prev2next[prev.id] = child.id
        @

    addInput: ([id, data]) ->
        @inputs[id] = data
        @run() if _.size(@inputs) >= @nclones

    run: ->
        keys = _.keys @inputs
        datas = _.values @inputs

        outputs = @compute datas

        for output, i in outputs
            childid = @prev2next[keys[i]]
            @emit "output-#{childid}", [@id, output]



class gg.Split extends gg.Node
    constructor: ->
        super

    findMatchingJoin: ->
        return null if @children.length is 0
        ptr = @children[0]
        n = 1
        while ptr?
            n += 1 if ptr.type is 'split'
            n -= 1 if ptr.type is 'join'
            break if n == 0
            ptr = if @children.length is 0 then null else @children[0]
        ptr

    split: (n) ->
        if @children.length > 0
            stop = @findMatchingJoin()
            while @children.length < n
                child = @children[0].clone @, stop
                @on "output-#{child.id}", child.addInput
                @children.push child

    run: ->
        _.partition @input, @gbfunc


class gg.Join extends gg.Node
    constructor: ->
        super

    addInput: ([id, data]) ->
        @inputs[id] = data
        if _.size(@inputs) == @nclones
            @run()

    clone: (prev, stop) ->
        if stop == @ or stop == @.id
            @nclones += 1
            @nodeId2cloneId[prev.id] = @nclones
            return @

        return super

    run: ->
        # merge tables together
        output = mergeTables(_.values @inputs)
        @emit "output", [@id, output]








# Workflow's job is to compose all nodes between a split and join/split
# into a composite node that can be executed in parallel (if desired)
#
# A workflow of all nodes between two connectors
#
# Clones nodes while it executes
class gg.SubWorkflow
    constructor: (@root) ->
        @curNode = @root
        @queue = []

    run: (tables) ->


    runUntilBlocker: (tables) ->

        while @curNode?
            switch @curNode.type
                when gg.wf.Types.NODE
                    break
                when gg.wf.Types.SPLIT

                    break
                when gg.wf.Types.JOIN
                    # joins within a workflow are strict joins
                    return tables

                    break
                when gg.wf.Types.CONNECT
                    break


class gg.Flow
    constructor: (@context) ->
        @nodes

    split: (func) ->
        nodes.push [split, func]
    apply: (func) ->
        nodes.push [apply, func]
    join: (func) ->
        nodes.push [join]
    run: (tables) ->
        for node in nodes
            if split
                tables = _.flatten _.map(tables, (table) => split(table, func))
            if apply
                tables = _.map tables, func
            if join
                tables = [_.reduce tables, merge]


###
new Flow()
    .apply(statsflow.run)
    .apply(scales.train)
    .apply(geomflow.run)
    .apply(scales.train)
    .apply(renderflow.run)
###




# Emits the following events
# - "



class gg.XForm
    constructor: (@spec, @mapper) ->
        @parent = null
        @child = null
        @type = gg.wf.Types.NODE

        # NOTE: schema = null means the schema matches whatever the data is
        @inSchema = ['var', 'group']    # default input schema
        @outSchema = []                 # default: no output

        @mapper.xform = @
        id = gg.wf.Node.id()


    @id: -> gg.wf.Node::_id += 1
    _id: 0


    clone: ->


    scales: -> null # some way of accessing the global scales

    name: (name) ->
        @name = name if name?
        @name

    detach: () ->
        @child.parent = null if @child?
        @child = @parent = null

    child: (@child) ->
        @child.parent = @
        @

    ensureSchema: (data) ->
        # if not data? or not data.length
        #   true
        if not @inSchema
            true

        # Ensure that mapper outputs the correct schema
        # TODO: required vs optional schemas
        _.every @inSchema, (aes) => @mapper.outputs aes

    mappedData: (table) -> @mapper.mapAll data


    # pool results from cloned children
    run: (tables) ->
        # execute
        #

    # children should override
    compute: (tables) ->
        throw "Node.compute() not implemented"


    @fromSpec: (spec) ->
        xformSpec = if spec? then spec.xform else 'identity'
        mapper = gg.Mapper.fromSpec spec

        new {
            identity: gg.IdentityStatistic,
            bin: gg.BinStatistic,
            box: gg.BoxPlotStatistic,
            sum: gg.SumStatistic
        }[xformSpec](spec, mapper)




class gg.Split    # 1 -> N
    constructor: (@gbfunc) ->
        super

        if typeof @gbfunc is "string"
            key = @gbfunc
            @gbfunc = (tuple) => tuple.get(key)

    preSplit: (table) -> table
    postSplit: (tables) -> tables

    run: (tables) ->
        table = tables[0]  # should only be one table as input

        table = @preSplit table
        tables = table.split @gbfunc
        tables = @postSplit tables

        # XXX: parallelize
        for table in tables
            @child.run table


class gg.Join     # N -> 1

    run: (tables) ->
        # XXX: ensure schemas are the same

        table = new gg.Table()
        _.map tables, table.merge
        @child.run [table]



class gg.Connect  # N -> N

    run: (tables) ->

        tables = @exec(tables)

        for table in tables
            @child.run([table])




###
spec: {
    xform/name: 'name of transformation'    // e.g., sum, boxplot..
    map/mapping/aes: { }                    // aesthetics mapping
    **kwargs                                // xform specific options
}

XForms include ggplot type statistics, sampling algorithms,
summarization algorithms
###
class gg.XForm
    constructor: (@spec, @mapper) ->
        # NOTE: schema = null means the schema matches whatever the data is
        @inSchema = ['var', 'group']    # default input schema
        @outSchema = []                 # default: no output

        @mapper.xform = @



