#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  @ggpackage = "gg.wf.Exec"
  @type = "exec"

  compute: (pairtable, params, cb) -> cb null, pairtable

  @finalize: (keyptPairs, masterPt) ->
    for [key, pt] in keyptPairs
      masterPt.update key, pt
    masterPt


  # partition by set of attributes
  # run UDF on each partition
  # merge partitions
  #
  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    pairtable = @inputs[0]

    keys = params.get 'keys'
    keys ?= pairtable.sharedCols()
    keys = _.intersection keys, pairtable.sharedCols()

    try
      pairtable = pairtable.partitionOn keys
      pairtable = pairtable.ensure keys
      partitions = pairtable.partition keys

      iterator = ([key, pt], cb) ->
        try
          compute pt, params, (err, pt) ->
            cb err, [key, pt]
        catch err
          console.log err.stack
          cb err, null

      async.map partitions, iterator, (err, keyptPairs) =>
        throw Error(err) if err?
        gg.wf.Exec.finalize keyptPairs, pairtable
        @output 0, pairtable

    catch err
      console.log err.stack
      throw Error(err)







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
    name = @name
    compute = (pairtable, params, cb) ->
      try
        res = f pairtable, params, () ->
          throw Error "SyncExec should not call callback"
        cb null, res
      catch err
        console.log("error in syncexec: #{name}")
        console.log err.stack
        cb err, null
    @params.put 'compute', compute

  compute: (pairtable, params, cb) -> pairtable



