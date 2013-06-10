#<< gg/util/*
#<< gg/data/table

try
  events = require 'events'
catch error
  console.log error

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
#   (table(s), env(s), params) -> table(s)
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
    @parents = []
    # mapping from parent node id to its input port
    @parent2in = {}

    # child nodes
    @children = []
    # input slot, one allocated for each input table expected
    @inputs = []

    # input port to output port mapping
    @in2out = {}
    # output port to child's input port
    @out2child = {}

    # workflow node belongs to
    # the workflow keeps track of execution state.
    @wf = @spec.wf or null

    # if this object is a clone instance, or a blueprint
    @isInstance = _.findGood [@spec.instance, no]
    # The blueprint
    @_base = @spec.base or null

    @id = gg.wf.Node.id()
    @type = _.findGood [@spec.type, "node"]
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    # Compute parameters
    @params = new gg.util.Params @spec.params


    @log = gg.util.Log.logger "#{@name}-#{@id}\t#{@constructor.name}", gg.util.Log.WARN

  @id: -> gg.wf.Node::_id += 1
  _id: 0

  @klassFromSpec: (spec) ->
    spec = _.clone spec
    class klass extends gg.wf.Exec
      constructor: (newspec) ->
        @spec = _.clone spec
        _.extend @spec, newspec
        _.extend @, @spec

        super @spec

    klass


  base: -> if @_base? then @_base else @
  childFromPort: (inPort) -> @children[0]
  uniqChildren: -> _.compact @children
  nChildren: -> @uniqChildren().length
  hasChildren: -> @nChildren() > 0
  toSpec: ->
    spec = _.clone @spec
    _.extend spec, {
      instance: yes
      base: @base()
      wf: @wf
      params: @params.clone()
    }
    spec

  # @return {[gg.wf.Node, Function]} where
  # - clone is a new copy of current node,
  # - f() is the input handler associated with the node
  #
  clone: (stop, klass=null) ->
    klass = @constructor unless klass?
    clone = new klass @toSpec()
    clone

  # Execution time call to create a copy of the workflow
  # instance rooted at current node.
  #
  # @return {[gg.wf.Node, Function]}
  cloneSubplan: (parent, parentPort, stop=null) ->
    clone = @clone stop
    cb = clone.addInputPort()

    if @nChildren() > 0
      [child, childCb] = @children[0].cloneSubplan @, 0, stop
      outputPort = clone.addChild child, childCb
      clone.connectPorts cb.port, outputPort, childCb.port
      child.addParent clone, outputPort, childCb.port
      @log "cloneSubplan: #{parent.name}-#{parent.id}(#{parentPort}) -> #{clone.name}-#{clone.id}(#{cb.port} -> #{outputPort}) -> #{child.name}#{child.id}(#{childCb.port})"

    [clone, cb]


  #
  # @return {Function}
  # Function that takes array pair [node.id, table] as input and
  # sets the appropriate input slot
  getAddInputCB: (idx) ->
    throw Error("input index #{idx} >= #{@inputs.length}") if idx >= @inputs.length

    cb = (node, data) =>
      #XXX what else could the data be?
      if _.isSubclass data, gg.data.Table
        data = new gg.wf.Data data

      if @inputs[idx]?
        throw Error("trying to add input to filled slot #{idx}")
      else
        @inputs[idx] = data

    cb.name = "#{@name}:#{@id}"
    cb.port = idx
    cb

  ready: -> _.all @inputs, (val) -> val?

  # @param {Int} outidx The index of the child the output should be routed to
  # Set an output handler.  Checks to make sure the index is valid
  addOutputHandler: (outidx, cb) ->
    @on outidx, cb if outidx >= 0 and outidx < @children.length

  output: (outidx, data) ->
    listeners = @listeners outidx
    n = listeners.length
    listeners = _.map(listeners, (l)->l.name)
    @log "output: port(#{outidx}) of #{n} #{listeners}\tenv: #{data.env.toString()}"
    @emit outidx, @, data
    @emit "output", @, data


  addInputPort: ->
    throw Error("#{@name} only supports <= 1 input port") if @inputs.length != 0
    @inputs.push null
    @getAddInputCB @inputs.length-1

  # Connects the input and output ports for a single node
  connectPorts: (input, output, childInPort) ->
    @log "connectPorts: (#{input} -> #{output}) -> #{childInPort}"
    @in2out[input] = [] unless input of @in2out
    @in2out[input].push output
    @out2child[output] = childInPort

  # Connects the parent's output port to this node's input port
  addParent: (parent, parentOPort, inputPort=null) ->
    throw Error("addParent inputPort not number #{inputPort}") unless _.isNumber inputPort
    @parents.push parent
    @parent2in[[parent.id, parentOPort]] = inputPort

  # allocates an output port for child
  #
  # @return ID for output port attached to child
  addChild: (child, childCb=null) ->
    childport = if childCb? then childCb.port else -1
    myStr = "#{@base().name} port(#{@nChildren()})"
    childStr = "#{child.base().name} port(#{childport})"
    #@log "addChild: -> #{myStr} -> #{childStr}"

    if @children.length > 0
      throw Error("#{@name}: Single Output node already has a child")

    @children.push child
    @addOutputHandler 0, childCb if childCb?
    0 # the output port Id



  #
  # The calling function is responsible for calling ready
  # run() will check if node is ready, but will throw an Error if so
  #
  #
  #
  run: -> throw Error("gg.wf.Node.run not implemented")


  # DFS of the workflow starting from this node
  walk: (f, seen=null) ->
    seen = {} unless seen?
    seen[@id] = yes

    f @

    for child in @uniqChildren()
      child.walk f, seen if child?





