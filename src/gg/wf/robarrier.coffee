#<< gg/wf/node

#
# Read only barrier --
#   the data table is read-only and throws error when projected 
#   or aggregated
#
# It doesn't make sense to combine _data_ across layers and facets.
#
# Multiinput -> tableset -> compute -> tableset -> multioutput
#
# Adds a hidden column (_barrier) to the data to track input and output ports
#
# 
class gg.wf.ROBarrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"

  compute: (pt, params, cb) -> cb null, pt

  @setup: (inputs) ->
    tables = _.map inputs, (pt) ->
      pt.left()

    mds = _.map inputs, (pt, idx) ->
      md = pt.right()
      md.setColVal '_barrier', idx

    table = new data.ops.Union tables
    md = new data.ops.Union mds
    new data.PairTable table, md


  @finalize: (inputs, tableset) ->
    lefts = _.map inputs, (pt) -> pt.left()
    right = tableset.right()
    rights = right.partition '_barrier', 'md'
    rights.map (row) ->
      idx = row.get '_barrier'
      left = lefts[idx]
      if (left.nrows() > 0)
        console.log(left.any().raw())
      right = row.get('md') or null
      right = right.exclude('_barrier') if right?
      {
        idx: idx
        pairtable: new data.PairTable left, right
      }

  run: ->
    throw Error("Node not ready") unless @ready()
    compute = @params.get('compute') or @compute.bind(@)

    try
      pairtable = gg.wf.ROBarrier.setup @inputs

      compute pairtable, @params, (err, tableset) =>
        throw err if err?
        console.log "finalizing #{@name}"
        results = gg.wf.ROBarrier.finalize @inputs, tableset
        for result in results
          idx = result.idx
          output = result.pairtable
          @output idx, output
    catch err
      console.log err.stack
      throw Error(err)
        

class gg.wf.SyncROBarrier extends gg.wf.ROBarrier
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
        

