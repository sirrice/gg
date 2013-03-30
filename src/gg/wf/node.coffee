#<< gg/util

try
  events = require 'events'
catch error
  console.log error

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
# :: Compute ::
#
# The @compute function that external users provide are of the following signature:
#
#   (table(s), env(s), node) -> table(s)
#
# The environment object is only used within the workflow, thus the input/output to
# the workflow is a table(s), and run() outputs a table
#
#
# The only nodes that modify the data's environment are Join and Split, which
# don't perform any computation.
#
# All other nodes (barrier, exec, multicast) need to pass the environment
# along to the child, e.g.,
#
#   table = @compute data, @
#   @output 0, {table: table, env: data.env}
#
#
class gg.wf.Node extends events.EventEmitter
  constructor: (@spec={}) ->
    # at least one output is expected per child
    @children = [null]

    @parents = []

    # a slot, filled with null, should be allocated for every expected input
    @inputs = [null]

    # workflow node belongs to
    # the workflow keeps track of execution state.
    @wf = @spec.wf or null

    # if this object is a clone, or a blueprint
    @isInstance = findGood [@spec.instance, no]
    @_base = @spec.base or null

    @id = gg.wf.Node.id()
    @type = "node"
    @name = findGood [@spec.name, "node-#{@id}"]

  @id: -> gg.wf.Node::_id += 1
  _id: 0

  base: -> if @_base? then @_base else @
  uniqChildren: -> _.compact @children
  nChildren: -> @uniqChildren().length
  hasChildren: -> @nChildren() > 0
  toSpec: ->
    spec = _.clone @spec
    _.extend spec, {
      instance: yes
      base: @base()
      wf: @wf
    }
    spec

  # @return {[gg.wf.Node, Function]} where
  # - clone is a new copy of current node,
  # - f() is the input handler associated with the node
  #
  clone: (stop, klass=null) ->
    @log "clone"
    klass = @constructor unless klass?
    clone = new klass @toSpec()
    [clone, clone.getAddInputCB 0]


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

    (node, data) =>
      if _.isSubclass data, gg.Table
        data = new gg.wf.Data data

      if @inputs[idx]?
        throw Error("trying to add input to filled slot #{idx}")
      else
        @inputs[idx] = data

  addInput: (idx, node, data) ->
    @getAddInputCB(idx)(node, data)

  log: (text) ->
    console.log "#{@name}-#{@id}\t#{@constructor.name}\t#{text}"

  ready: -> _.all @inputs, (val) -> val?

  # @param {Int} outidx The index of the child the output should be routed to
  # Set an output handler.  Checks to make sure the index is valid
  addOutputHandler: (outidx, cb) ->
    @on outidx, cb if outidx >= 0 and outidx < @children.length

  output: (outidx, data) ->
    @log "outputing to port #{outidx}"
    @emit outidx, @, data
    @emit "output", @, data

  addParent: (node) ->
    @log "addParent #{node.name}-#{node.id} #{node.constructor.name}"
    @parents.push node

  addChild: (node, inputCb=null) ->
    if @children[0]?
      throw Error("#{@name}: Single Output node already has a child")
    @children[0] = node
    @addOutputHandler 0, inputCb if inputCb?
    node.addParent @




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

    for child in @uniqChildren()
      child.walk f, seen if child?


# Add group pair into the environment.  Abstractly:
#
#   env.push {key: val}
#
# used by first xform in layer to name the rest of the workflow
#
# spec.key  label name e.g., "layer"
# spec.val  label value e.g., "layer-2"
#           also: spec.value
# spec.f    function to dynamically compute label value
#
class gg.wf.Label extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @key = @spec.key
    @compute = findGood [@spec.val, @spec.value, @spec.f, null]
    @type = "label"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    unless @key?
      throw Error("#{@name}: Did not define a label key and value/value function)")

  run: ->
    throw Error("#{@name}: node not ready") unless @ready()

    data = @inputs[0]
    if _.isFunction @compute
      val = @compute data.table, data.env, @
    else
      val = @compute

    console.log "#{@name}: adding label #{@key} -> #{val}"

    env = data.env.clone()
    env.pushGroupPair @key, val
    @output 0, new gg.wf.Data(data.table, env)
    data.table



class gg.wf.Source extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @compute = @spec.f or @compute
    @type = "source"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]

  compute: -> throw Error("#{@name}: Source not setup to generate tables")
  ready: -> yes

  run: ->
    # always ready!
    table = @compute()
    @output 0, new gg.wf.Data(table, new gg.wf.Env)
    table



#
class gg.wf.Exec extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @compute = @spec.f or @compute
    @type = "exec"
    @name = findGood [@spec.name, "exec-#{@id}"]

  compute: (table, env, node) -> table


  # @return emits to "output-child.id"
  run: ->
    throw Error("node not ready") unless @ready()

    data = @inputs[0]
    output = @compute data.table, data.env, @
    @output 0, new gg.wf.Data(output, data.env.clone())
    output

class gg.wf.Stdout extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "stdout"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    @n = findGood [@spec.n, null]

  compute: (table, env, node) ->
    table.each (row, idx) =>
      if @n is null or idx < @n
        console.log JSON.stringify(_.omit(row, ['get', 'ncols']))
    table


#
# @compute(tables) -> tables
# The compute function takes a list of N tables and outputs N tables
# such that the positions of the input and output tables match up
#
class gg.wf.Barrier extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @compute = @spec.f or @compute
    @type = "barrier"
    @name = findGood [@spec.name, "barrier-#{@id}"]

    # pointer to the next workflow child to clone when
    # cloneSubplan is called.
    #
    # each call to cloneSubplan increments clonePtr
    #
    # if clonePtr < number of children in the @wf
    #   return existing input callback
    # otherwise
    #   clone child clonePtr%nChildren
    #   return new child's input cb
    #
    @clonePtr = 0

  compute: (tables, env, node) -> tables


  cloneSubplan: (stop) ->
    #@inputs.push null

    # clone @children[0..n] where n is the number of
    # children in the workflow
    nChildren = @wf.children(@base()).length

    idx = @clonePtr % nChildren
    [child, childInputCB] = @children[idx].cloneSubplan stop
    @addChild child, childInputCB
    @clonePtr = (@clonePtr+1) % nChildren

    [this, @getAddInputCB @nChildren()-1]

  addChild: (child, inputCb=null) ->
    if @children[0]?
      @children.push child
      @inputs.push null
    else
      @children[0] = child

    @addOutputHandler @nChildren()-1, inputCb if inputCb?
    child.addParent @

    @log "addChild #{child.name}-#{child.id} to port #{@nChildren()-1}\t #{@inputs.length} in #{@nChildren()} out"


  run: ->
    throw Error("Node not ready") unless @ready()
    tables = _.pluck @inputs, 'table'
    envs = _.pluck @inputs, 'env'
    outputs = @compute tables, envs, @
    console.log "#{@name} barrier got #{tables.length}"
    for output, idx in outputs
      @output idx, new gg.wf.Data(output, envs[idx].clone())
    outputs


#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    # TODO: support groupby functions that return an
    # array of keys.
    @type = "split"
    @name = findGood [@spec.name, "split-#{@id}"]
    @gbkeyName = findGood [@spec.key, @name]
    @splitFunc = findGood [@spec.f, @splitFunc]

  # @return array of {key: String, table: gg.Table} dictionaries
  splitFunc: (table, env, node) -> []

  findMatchingJoin: ->
    ptr = @children[0]
    n = 1
    while ptr?
      n += 1 if ptr.type is 'split'
      n -= 1 if ptr.type is 'join'
      break if n == 0
      ptr = if ptr.hasChildren() then ptr.children[0] else null
    ptr

  allocateChildren: (n) ->
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
    child.addParent @

  run: ->
    throw Error("Split not ready, expects #{@inputs.length} inputs") unless @ready()
    data = @inputs[0]
    table = data.table
    env = data.env

    groups = @splitFunc table, env, @
    unless groups? and _.isArray groups
      throw Error("#{@name}: Non-array result from calling split function")

    numDuplicates = groups.length

    # TODO: parameterize MAXGROUPS threshold
    if numDuplicates > 1000
      throw Error("I don't want to support more than 1000 groups!")

    @allocateChildren numDuplicates
    idx = 0
    _.each groups, (group) =>
      subtable = group.table
      key = group.key
      newData = new gg.wf.Data subtable, data.env.clone()
      newData.env.pushGroupPair @gbkeyName, key
      @output idx, newData
      idx += 1
    groups

class gg.wf.Partition extends gg.wf.Split
  constructor: ->
    super

    @name = findGood [@spec.name, "partition-#{@id}"]
    @gbfunc = @spec.f or @gbfunc
    @splitFunc = (table) -> table.split @gbfunc

  gbfunc: -> 1



#
# Does not compute anything
class gg.wf.Join extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @type = "join"
    @name = findGood [@spec.name, "join-#{@id}"]

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

  # pop from each env's keys list
  run: ->
    unless @ready()
      throw Error("#{@name} not ready: #{@inputs.length} of #{@children().length} inputs")

    tables = _.map @inputs, (data) =>
      table = data.table
      groupPair = data.env.popGroupPair()
      colName = groupPair.key
      colVal = groupPair.val
      newCol = _.times table.nrows(), ()->colVal
      table.addColumn colName, newCol
      table

    env = @inputs[0].env.clone()
    output = gg.Table.merge _.values(tables)
    @output 0, new gg.wf.Data output, env

    output


#
# Has an ordered list of children.  Replicates input to children.
#
# ONET: ONLY workflow node with multiple children at compile time!
#
class gg.wf.Multicast extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @type = "multicast"
    @name = findGood [@spec.name, "multicast-#{@id}"]


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
    node.addParent @
    @addOutputHandler @children.length-1, inputCb if inputCb?

  run: ->
    throw Error("Node not ready") unless @ready()

    data = @inputs[0]
    for child, idx in @children
      newData = data.clone()
      @output idx, newData
    data.table

###
class gg.wf.Composite extends gg.wf.Node

    constructor: (@spec={}) ->
        super @spec

        @nodes = @spec.nodes
        @type = "composite"
        @name = findGood [@spec.name, "comp-#{@id}"]

    clone: (stop) ->
        nodes = []

###
