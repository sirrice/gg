#<< gg/wf/node

#
# Full access barrier
#   the data table can be modified
#   slower than ROBarrier
#
# It doesn't make sense to combine _data_ across layers and facets.
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
    tables = _.map inputs, (pt, idx) ->
      t = pt.left()
      t.setColVal '_barrier', idx

    mds = _.map inputs, (pt, idx) ->
      md = pt.right()
      md.setColVal '_barrier', idx

    table = new data.ops.Union tables
    md = new data.ops.Union mds
    new data.PairTable table, md


  @finalize: (tableset) ->
    table = tableset.left()
    md = tableset.right()
    timer = new gg.util.Timer()
    table = table.partition '_barrier', 'table'
    timer.start()
    oldmd = md
    md = md.partition '_barrier', 'md'
    timer.stop()

    if timer.sum() > 200
      console.log("finalize took ttoo long")
      console.log timer.toString()
      console.log timer.timings()
      console.log oldmd.graph()

    pairtable = table.join md, '_barrier' 
    pairtable.map (row) =>
      table = row.get('table')
      md = row.get('md') or null
      table = table.exclude('_barrier') if table?
      md = md.exclude('_barrier') if md?
      idx = row.get '_barrier'
      {
        idx: idx
        pairtable: new data.PairTable(table, md)
      }


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
        

