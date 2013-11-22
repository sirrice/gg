#<< gg/wf/node

# Sends the entire pairtable (without partitioning first like Exec
# or Barrier) to the compute
class gg.wf.Block extends gg.wf.Node
  @ggpackage = "gg.wf.Block"
  @type = "block"

  compute: (pairtable, params, cb) -> cb null, pairtable

  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)

    compute @inputs[0], params, (err, pairtable) =>
      throw Error(err) if err?
      @output 0, pairtable


class gg.wf.SyncBlock extends gg.wf.Block
  parseSpec: ->
    super
    name = @name
    f = @params.get 'compute'
    f ?= @compute.bind(@)
    compute = (pairtable, params, cb) ->
      try
        res = f pairtable, params, () ->
          throw Error "SyncBlock should not call callcack"
        cb null, res
      catch err
        console.log "error in syncblock #{name}"
        console.log err.stack
        cb err, null
    @params.put 'compute', compute

  compute: (pairtable, params, cb) -> pairtable
