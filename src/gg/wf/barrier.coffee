#<< gg/wf/node

#
# Multiinput -> tableset -> compute -> tableset -> multioutput
#
# Adds a hidden column (_barrier) to the data to track input and output ports
# 
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"

  compute: (tableset, params, cb) -> cb null, tableset

  run: ->
    throw Error("Node not ready") unless @ready()
    compute = @params.get('compute') or @compute.bind(@)

    pairtables = _.map @inputs, (pt, idx) ->
      t = pt.getTable()
      t = t.addConstColumn '_barrier', idx
      md = pt.getMD()
      md = md.addConstColumn '_barrier', idx
      new gg.data.PairTable t, md

    tableset = new gg.data.TableSet pairtables
    compute tableset, @params, (err, tableset) =>
      if err?
        throw err
      ps = gg.data.Transform.partitionJoin tableset.getTable(), tableset.getMD(), '_barrier'
      for p in ps
        idx = p['key']
        result = p['table']
        t = result.getTable().rmColumn '_barrier'
        result = new gg.data.PairTable t, result.getMD()
        @output idx, result

        

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
          console.log err.toString()
          cb err, null
    @params.put 'compute', makecompute(f)
        

