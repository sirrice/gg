#<< gg/wf/node


# Has an ordered list of children.  Replicates input to children.
#
# ONET: ONLY workflow node with multiple children at compile time!
#
class gg.wf.Multicast extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @type = "multicast"
    @name = _.findGood [@spec.name, "multicast-#{@id}"]


  cloneSubplan: (parent, parentPort, stop) ->
    clone = @clone stop
    cb = clone.addInputPort()

    for child, idx in _.compact @children
      [child, childCb]  = child.cloneSubplan @, idx, stop
      outputPort = clone.addChild child, childCb
      clone.connectPorts cb.port, outputPort, childCb.port
      child.addParent clone, outputPort, childCb.port
      @log "cloneSubplan: #{parent.name}-#{parent.id}(#{parentPort}) -> me(#{cb.port} -> #{outputPort}) -> #{child.name}-#{child.id}(#{childCb.port})"

    [clone, cb]

  addChild: (node, inputCb=null) ->
    @children.push node
    @addOutputHandler @nChildren()-1, inputCb if inputCb?
    @nChildren()-1

  run: ->
    throw Error("Node not ready") unless @ready()

    data = @inputs[0]
    for child, idx in @children
      newData = data.clone()
      @output idx, newData
    data.table

