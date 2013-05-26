#<< gg/wf/node

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
    @name = _.findGood [@spec.name, "barrier-#{@id}"]

  compute: (tables, env, node) -> tables

  addInputPort: ->
    @inputs.push null
    @getAddInputCB @inputs.length - 1

  childFromPort: (inPort) ->
    outPort = @in2out[inPort]
    @children[outPort]

  # Looks up the correct child node for @parent before cloning
  # @param parent parent node
  # @param parentPort parent's output port connected to this node
  #
  cloneSubplan: (parent, parentPort, stop) ->
    inPort = @parent2in[[parent.id, parentPort]]

    unless inPort?
      throw Error("no input port for parent: #{parent.toString()}")
    unless @in2out[inPort]?
      throw Error("no matching output port for input port #{inPort}")
    if @in2out[inPort].length != 1
      throw Error("Barrier input port maps to #{@in2out[inPort].length} output ports")

    child = @children[@in2out[inPort][0]]

    [child, childCb] = child.cloneSubplan @, @in2out[inPort], stop
    outputPort = @addChild child, childCb
    cb = @addInputPort()
    @connectPorts cb.port, outputPort, childCb.port
    child.addParent @, outputPort, childCb.port

    @log "cloneSubplan: #{parent.name}-#{parent.id}(#{parentPort}) -> me(#{cb.port} -> #{outputPort}) -> #{child.name}-#{child.id}(#{@in2out[inPort]})"

    [@, cb]

  addChild: (child, inputCb=null) ->
    childport = if inputCb? then inputCb.port else -1
    myStr = "#{@base().name} port(#{@nChildren()})"
    childStr = "#{child.base().name} port(#{childport})"
    #@log "addChild #{myStr} -> #{childStr}"

    outputPort = @nChildren()
    @children.push child
    @addOutputHandler outputPort, inputCb if inputCb?
    outputPort


  run: ->
    throw Error("Node not ready") unless @ready()

    tables = _.pluck @inputs, 'table'
    envs = _.pluck @inputs, 'env'
    outputs = @compute tables, envs, @
    @log "barrier got #{tables.length}"

    for output, idx in outputs
      @output idx, new gg.wf.Data(output, envs[idx].clone())
    outputs


