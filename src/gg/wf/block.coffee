#<< gg/wf/node

# Sends the entire pairtable (without partitioning first like Exec
# or Barrier) to the compute
class gg.wf.Block extends gg.wf.Node
  @ggpackage = "gg.wf.Block"
  @type = "block"

  parseSpec: ->
    @params.ensure 'compute', ['f'], null

  compute: (pairtable, params, cb) -> cb null, pairtable

  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    pstore = @pstore()
    compute = @params.get('compute') or @compute.bind(@)

    tset = new gg.data.TableSet [@inputs[0]]
    compute tset, params, (err, pairtable) =>
      throw Error(err) if err?
      @output 0, pairtable

    ###
    # Write provenance
    pstore = @pstore()
    id2path = _.o2map flat, (data, idx) -> [data.id, paths[idx]]
    for data, idx in newdatas
      if data.id of id2path
        pstore.writeData [idx], id2path[data.id]
      else
        pstore.writeData [idx], null
    ###



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
        console.log err.toString()
        cb err, null
    @params.put 'compute', compute

  compute: (pairtable, params, cb) -> pairtable
