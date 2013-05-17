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

  run: () ->
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

        cur.run()
        seen[cur.id] = yes

        for nextNode in _.compact(_.flatten cur.children)
          queue.push nextNode unless nextNode of seen
      else
        filled = _.map cur.inputs, (v) -> v?
        @log "not ready #{cur.name} id: #{cur.id}.  #{cur.inputs.length}, #{cur.children.length}"
        if firstUnready is cur
          if nprocessed == 0
            @log "#{cur.name} inputs buffer: #{cur.inputs.length}"
            @log "#{cur.name} ninputs filled: #{filled}"
            @log "#{cur.name} parents: #{_.map(cur.parents, (p)->p.name).join(',')}"
            @log "#{cur.name} children: #{_.map(cur.children, (p)->p.name).join(',')}"

            throw Error("could not make progress.  Stopping on #{cur.name}")
          else
            firstUnready = null

        unless firstUnready?
            firstUnready = cur
            nprocessed = 0
        queue.push cur

    @emit "done", yes


