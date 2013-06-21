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
  constructor: (@root) ->
    @log = gg.util.Log.logger "Runner", gg.util.Log.WARN
    @active = {}
    @seen = {}
    @keyf = (node) -> node.id
    @rpcnodes = {}

    runNode = (node) ->
      #var blob = new Blob ["onmessage = function() { console.log(gg);  }"]
      #var worker = new Worker(window.URL.createObjectURL(blob))
      node.run()

    # Execute a workflow node
    qworker = (node, cb) =>
      if node.id of @seen
        console.log "\t#{node.name} seen. skipping"
        cb()
        return

      # queue will naturally be cleared of all non-ready nodes
      unless node.ready()
        console.log "\t#{node.name} not ready.
          #{node.nReady()} of #{node.inputs.length} inputs ready"
        cb()
        return


      if node.nChildren() > 0
        node.on 'output', (skip, result) =>
          for child in node.uniqChildren()
            console.log "\tadding #{child.name}"
            @queue.push child, @callback

          if node.nChildren() == 0
            @emit 'output', node, result.table

          delete @active[node.id]
          cb()

      @active[node.id] = node
      @seen[node.id] = yes
      runNode(node)

    # this does nothing
    callback = (err) =>
      throw Error(err) if err?

    ondrain = () =>
      unless _.size @active
        console.log "done! can you believe it?"
        @emit 'done', yes



    @queue = new async.queue qworker, 1
    @queue.drain = ondrain.bind(@)


  run: () ->
    @queue.push @root, @callback



