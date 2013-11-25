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

  # partition by set of attributes
  # run UDF on each partition
  # merge partitions
  #
  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    log = @log

    try
      tableset = @inputs[0]
      keys = params.get 'keys'
      keys ?= tableset.sharedCols()
      tableset = tableset.ensure keys
      partitions = tableset.partition(keys)

      iterator = (pt, cb) ->
        try
          compute pt, params, cb
        catch err
          console.log err.stack
          cb err, null

      async.map partitions, iterator, (err, pairtables) =>
        throw Error(err) if err?
        pairtables = _.map pairtables, (pt) ->
          md = pt.right()
          t = pt.left()
          for col in keys
            v = md.any col
            t = t.setColVal col, v
          new data.PairTable t, md

        table = new data.ops.Union _.map(pairtables, (pt) -> pt.left())
        md = new data.ops.Union _.map(pairtables, (pt) -> pt.right())

        @output 0, new data.PairTable(table, md)
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



