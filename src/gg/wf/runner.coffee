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
  constructor: (@flow) ->
    @log = gg.util.Log.logger "Runner", gg.util.Log.WARN
    @active = {}
    @seen = {}
    @keyf = (node) -> node.id
    @rpcnodes = {}

    runNode = (node) =>
      #var blob = new Blob ["onmessage = function() { console.log(gg);  }"]
      #var worker = new Worker(window.URL.createObjectURL(blob))
      @log "#{node.name} in(#{node.inputs.length}) out(#{node.nChildren}) running"
      node.run()

    nodeCanRun = (node) =>
      if node.id of @seen
        @log "\t#{node.name} seen. skipping"
        return no

      # queue will naturally be cleared of all non-ready nodes
      unless node.ready()
        @log "\t#{node.name} not ready.
          #{node.nReady()} of #{node.inputs.length} inputs ready"
        return no

      yes

    setChildInputs = (node, idx, input) =>
      children = @flow.portGraph.children({n: node, p: idx})
      if children.length != 1
        throw Error
      o = children[0]
      child = o.n
      inport = o.p

      @log "setInput #{node.name}:#{idx}-> #{child.name}:#{inport}"
      child.setInput inport, input

      if child.ready()
        @log "\t#{child.name} adding"
        @queue.push child, @callback
      else
        @log "\t#{child.name} not ready
          #{child.nReady()} of #{child.nParents} ready"


    # Execute a workflow node
    qworker = (node, cb) =>
      unless nodeCanRun node
        cb()
        return

      node.on 'output', (idx, result) =>
        @log "#{node.name} got output in port #{idx}"
        if node.nChildren == 0
          # not sure what the semantics should be for flow's output
          @emit 'output', idx, result
        else
          setChildInputs node, idx, result

        delete @active[node.id]
        cb()

      @active[node.id] = node
      @seen[node.id] = yes
      runNode(node)

    # this does nothing
    callback = (err) =>
      throw Error(err) if err?

    ondrain =  =>
      unless _.size @active
        @log "done! can you believe it?"
        @log @
        @emit 'done', yes


    @queue = new async.queue qworker, 1
    @queue.drain = ondrain


  run: () ->
    @log "adding sources"
    _.each @flow.sources(), (source) =>
      @log "adding source #{source.name}"
      @queue.push source, @callback



