#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  @ggpackage = "gg.wf.Exec"
  @type = "exec"

  parseSpec: ->
    @params.ensure 'compute', ['f'], null

  compute: (pairtable, params, cb) -> cb null, pairtable

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    pstore = @pstore()
    log = @log

    tableset = new gg.data.TableSet @inputs
    partitions = tableset.fullPartition()
    #partitions = tableset.partition @params.get('key')
    iterator = (pairtable, cb) ->
      try
        log "calling compute in wf.exec"
        compute pairtable, params, cb
      catch err
        cb err, null
    async.map partitions, iterator, (err, pairtables) =>
      throw Error err if err?
      result = new gg.data.TableSet pairtables
      @output 0, result


  @create: (params=null, compute) ->
    params ?= new gg.util.Params
    class Klass extends gg.wf.Exec
      compute: (pairtable, params, cb) ->
        compute pairtable, params, cb
    new Klass
      params: params





# Assumes @compute runs synchronously and errors come from
# exceptions
#
# @compute should _not_ accept not call the callback
#
class gg.wf.SyncExec extends gg.wf.Exec
  parseSpec: ->
    super
    f = @params.get 'compute'
    f ?= @compute.bind(@)
    compute = (pairtable, params, cb) ->
      try
        res = f pairtable, params, () ->
          throw Error "SyncExec should not call callback"
        cb null, res
      catch err
        console.log(err)
        cb err, pairtable
    @params.put 'compute', compute

  compute: (pairtable, params, cb) -> pairtable

  @create: (params=null, compute) ->
    params ?= new gg.util.Params
    class Klass extends gg.wf.SyncExec
      compute: (pairtable, params, cb) ->
        compute pairtable, params, cb
    new Klass
      params: params


