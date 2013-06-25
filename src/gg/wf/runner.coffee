#<< gg/util/log



# Executes an instantiated workflow
# Single threaded javascript implementation
#
# 1. A job pool is necessary when executing the workflow instance, so that the
#    system doesn't generate too many threads.
# 2. An alternative is for each node to be locally responsible for spawning at most
#    X threads, and bundling groups of child nodes together to run synchronously
#
#
# States:
#
# making progress
#   active.length > 0
#
# can't make progress
#   active.length = 0
#   nothing in queue is ready
#
# done
#   active.length = 0
#   queue.length = 0
#
class gg.wf.Runner extends events.EventEmitter
  constructor: (@flow, xferControl) ->
    @log = gg.util.Log.logger "Runner", gg.util.Log.WARN
    @done = {}
    @seen = {}
    @setupQueue()

    @ch = new gg.wf.ClearingHouse(
      @, xferControl)

    # every node's output goes through the clearing house
    @flow.graph.bfs (node) =>
      node.on "output", @ch.push.bind(@ch)


  setupQueue: ->
    # Execute a workflow node
    qworker = (node, cb) =>
      unless @nodeCanRun node
        cb()
        return

      @seen[node.id] = yes
      @runNode(node)
      cb()

    ondrain =  ()=>
      sources = @flow.sources()
      unless _.all(sources, (s) => @done[s.id])
        @log "done! can you believe it?"
        @emit 'done', yes


    @queue = new async.queue qworker, 1
    @queue.drain = ondrain

  runNode: (node) ->
    @log "#{node.name} in(#{node.inputs.length})
          out(#{node.nChildren}) running"
    node.run()

  nodeCanRun: (node) ->
    if node.id of @seen
      @log "\t#{node.name} seen. skipping"
      return no

    # queue will naturally be cleared of all non-ready nodes
    unless node.ready()
      @log "\t#{node.name} skip:
            #{node.nReady()} of #{node.nParents} inputs ready"
      return no

    yes

  run: () ->
    _.each @flow.sources(), (source) =>
      @log "adding source #{source.name}"
      @queue.push source


class gg.wf.ClearingHouse extends events.EventEmitter
  constructor: (@runner, @xferControl) ->
    @flow = @runner.flow
    @log = gg.util.Log.logger "clearinghouse"


  push: (nodeid, outport, outputs) ->
    if @isSink(nodeid)
      @emit "output", nodeid, outport, outputs
    else if @clientToServer nodeid, outport
      @xferControl nodeid, outport, outputs
    else if @serverToClient nodeid, outport
      @xferControl nodeid, outport, outputs
    else
      @runner.done[nodeid] = yes
      @routeNodeResult nodeid, outport, outputs


  clientToServer: (nodeid, outport) ->
    node = @flow.nodeFromId nodeid
    return no unless node.location is "client"
    children = @flow.portGraph.children
      n: node
      p: outport
    console.log [node.name, nodeid, outport]
    console.log children
    o = children[0]
    child = o.n
    inport = o.p

    child.location is "server"


  serverToClient: (nodeid, outport) ->
    node = @flow.nodeFromId nodeid
    return no unless node.location is "server"
    children = @flow.portGraph.children({n: node, p: outport})
    console.log [node.name, nodeid, outport]
    console.log children
    o = children[0]
    child = o.n
    inport = o.p

    child.location is "client"

  isSink: (nodeid) ->
    nodeid in _.map(@flow.sinks(), (sink) -> sink.id)

  routeNodeResult: (nodeid, outport, input) ->
    node = @flow.nodeFromId nodeid
    children = @flow.portGraph.children
      n: node
      p: outport
    if children.length != 1
      throw Error("children should only be 1")

    o = children[0]
    child = o.n
    inport = o.p

    @log "setInput #{node.name}:#{outport} ->
          #{child.name}:#{inport} of #{child.inputs.length}"

    child.setInput inport, input
    console.log child.inputs[inport]

    if child.ready()
      @log "\t#{child.name} adding"
      @runner.queue.push child
    else
      @log "\t#{child.name} not ready
        #{child.nReady()} of #{child.nParents} ready"



