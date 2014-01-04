#<< gg/wf/node

#
# Full access barrier
#   the data table can be modified
#   slower than ROBarrier
#
# XXX: It doesn't make sense to combine _data_ across layers and facets.
#
# Multiinput -> tableset -> compute -> tableset -> multioutput
#
# Adds a hidden column (_barrier) to the data to track input and output ports
#
# 
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"

  compute: (pt, params, cb) -> cb null, pt

  @setup: (inputs) ->
    inputs = for pt in inputs
      pt.partitionOn []
    inputs = for pt, idx in inputs
      pt.addSharedCol '_barrier', idx, data.Schema.numeric
    pt = data.PartitionedPairTable.fromPairTables inputs

  @finalize: (tableset) ->
    tableset = tableset.partitionOn '_barrier'
    partitions = tableset.table.partition '_barrier'

    ret = partitions.map (row) ->
      outidx = row.get '_barrier'
      ppt = new data.PartitionedPairTable(
        row.get 'table'
        tableset.cols
        tableset.lschema
        tableset.rschema
      )
      {
        idx: outidx
        pairtable: ppt.rmSharedCol('_barrier')
      }

    ret

  run: ->
    throw Error("Node not ready") unless @ready()
    compute = @params.get('compute') or @compute.bind(@)

    try
      pairtable = gg.wf.Barrier.setup @inputs

      compute pairtable, @params, (err, tableset) =>
        throw err if err?
        results = gg.wf.Barrier.finalize tableset
        for result in results
          idx = result.idx
          output = result.pairtable
          @output idx, output
    catch err
      console.log err.stack
      throw Error(err)
        

class gg.wf.SyncBarrier extends gg.wf.Barrier
  parseSpec: ->
    super
    f = @params.get 'compute'
    f ?= @compute.bind @
    name = @name
    makecompute = (f) ->
      (pairtable, params, cb) ->
        try
          res = f pairtable, params, () ->
            throw Error "SyncBarrier should not call callback"
          cb null, res
        catch err
          console.log "err in SyncBarrier #{name}"
          console.log err.stack
          cb err, null
    @params.put 'compute', makecompute(f)
        

