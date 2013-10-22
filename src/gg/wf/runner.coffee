#<< gg/util/log
#<< gg/wf/clearinghouse

try
  timer = performance
catch err
  timer = Date


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

    @ch = new gg.wf.ClearingHouse @, null
    @ch.on "output", (args...) => @emit "output", args...
    @ch.xferControl = xferControl if xferControl?

    # every node's output goes through the clearing house
    @flow.graph.bfs (node) =>
      node.on "output", (args...) =>
        if node.id of @debug
          o = @debug[node.id]
          o['end'] = timer.now()
          o['cost'] = o['end'] - o['start']
        @ch.push args...

    @debug = {}


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
      if _.all(@flow.sinks(), (s) => @done[s.id])
        @log "done! can you believe it?"
        @emit 'done', @debug

    @queue = new async.queue qworker, 1
    @queue.drain = ondrain

  runNode: (node) ->
    @log "runNode: #{node.name} in(#{node.inputs.length})
          out(#{node.nChildren}) running"
    @debug[node.id] = 
      start: timer.now()
      name: node.name
      id: node.id
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



