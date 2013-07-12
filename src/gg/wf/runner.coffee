#<< gg/util/log
#<< gg/wf/clearinghouse



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
  @ggpackage = "gg.wf.Runner"

  constructor: (@flow, xferControl) ->
    @log = gg.util.Log.logger @constructor.ggpackage, "Runner"
    @done = {}
    @seen = {}
    @setupQueue()

    @ch = new gg.wf.ClearingHouse(
      @, null)
    @ch.on "output", (args...) => @emit "output", args...
    unless xferControl?
      xferControl = @ch.routeNodeResult.bind(@ch)
    @ch.xferControl = xferControl

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

    ondrain =  () =>
      sources = @flow.sources()
      unless _.all(sources, (s) => @done[s.id])
        @log "done! can you believe it?"
        @emit 'done', yes

    @queue = new async.queue qworker, 1
    @queue.drain = ondrain

  runNode: (node) ->
    @log "runNode: #{node.name} in(#{node.inputs.length})
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

  # mark node id as completed
  setDone: (nodeid) ->
    if nodeid?
      @done[nodeid] = yes

  # add node to the queue and see if it will run.
  tryRun: (node) ->
    @queue.push node


  run: () ->
    _.each @flow.sources(), (source) =>
      @log "adding source #{source.name}"
      @queue.push source



