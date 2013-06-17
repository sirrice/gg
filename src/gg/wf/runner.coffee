#<< gg/util/log



# Executes an instantiated workflow
# Single threaded javascript implementation
#
# 1. A job pool is necessary when executing the workflow instance, so that the
#    system doesn't generate too many threads.
# 2. An alternative is for each node to be locally responsible for spawning at most
#    X threads, and bundling groups of child nodes together to run synchronously
#
class gg.wf.Runner extends events.EventEmitter
  constructor: (@root) ->
    @log = gg.util.Log.logger "Runner", gg.util.Log.WARN
    @active = {}
    @seen = {}
    @keyf = (node) -> node.id

    worker = (node, cb) =>
      if node.id of @seen
        console.log "\t#{node.name} seen. skipping"
        cb()
        return

      # queue will naturally be cleared of all non-ready nodes
      unless node.ready()
        console.log "\t#{node.name} not ready. skipping"
        cb()
        return

      if node.nChildren() > 0
        finalIdx = node.nChildren() - 1
        console.log "\t#{node.name}: finalIdx #{finalIdx}"
        node.on 'output', (skip, result) =>
          try
            for child in node.uniqChildren()
              console.log "\tadding #{child.name}"
              @queue.push child, @callback
          catch err
            console.log err

          delete @active[node.id]
          cb()
      else
        console.log "\t#{node.name}: no children!"
        node.on 'output', (skip, result) =>
          @emit 'output', node, result.table
          cb()

      console.log "\t#{node.name} running"
      @active[node.id] = node
      @seen[node.id] = yes
      node.run()

    # this does nothing
    callback = (err) =>
      throw Error(err) if err?


    ondrain = () =>
      # can't differentiate between
      # 1) no active processes because we are done
      # 2) no active processes because we can't make progress
      #
      # XXX: compare with list of all nodes in the graph and see that they have all been seen
      unless _.size @active
        console.log "done! can you believe it?"
        @emit 'done', yes


    # Detect:
    #
    # Doesn't work for split, because its children are dynamically
    # set
    #
    # making progress
    #   active.length > 0
    #
    # can't make progress
    #   no active processes
    #   nothing in queue is ready
    #
    # done
    #   active is empty
    #   queue is drained


    @queue = new async.queue worker, 1
    @queue.drain = ondrain.bind(@)


  run: () ->
    @queue.push @root, @callback
    return



    queue = new gg.util.UniqQueue [@root]

    seen = {}
    results = []
    nprocessed = 0
    firstUnready = null

    until queue.empty()
      cur = queue.pop()
      continue unless cur?
      continue if cur.id of seen


      @log "run #{cur.name} id:#{cur.id} with #{cur.nChildren()} children"
      if cur.ready()
        nprocessed += 1

        unless cur.nChildren()
          # cur is a sink, register output handler for it
          cur.addOutputHandler 0, (id, result) =>
            @emit "output", id, result.table
        else
          # XXX: hack to detect when a node (normal or barrier)
          #      has finished by using output port nchildren-1
          #
          #      Avoids decrementing a counter for every
          #      "output" emitted
          cur.on (cur.nChildren()-1), (node, result) ->
            for nextNode in cur.uniqChildren()
              queue.push nextNode unless nextNode.id of seen

            # trigger something

        cur.run()
        seen[cur.id] = yes

        #
        #
        #
        # Needs to block while all ready nodes are actively
        # executing and resume + check when any of the
        # nodes finish (e.g., emit outputs)
        #
        #
        #

      else
        @log.warn "not ready #{cur.name} id: #{cur.id}.
          #{cur.inputs.length}, #{cur.children.length}"

        if firstUnready is cur
          if nprocessed == 0
            filled = _.map cur.inputs, (v) -> v?
            @log.error "#{cur.name} inputs buffer: #{cur.inputs.length}"
            @log.error "#{cur.name} ninputs filled: #{filled}"
            @log.error "#{cur.name} parents: #{_.map(cur.parents, (p)->p.name).join(',')}"
            @log.error "#{cur.name} children: #{_.map(cur.children, (p)->p.name).join(',')}"

            throw Error("could not make progress.  Stopping on #{cur.name}")
          else
            firstUnready = null

        unless firstUnready?
            firstUnready = cur
            nprocessed = 0
        queue.push cur

    @emit "done", yes


