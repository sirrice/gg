#<< gg/wf/node

# Flattens (irreversibly) and processes all wf.Data objects for a layer
# Expect that wf.Data objects are mutated in place or added, but 
# not replaced -- ids for the same "logical" Data don't change.
class gg.wf.Block extends gg.wf.Node
  @ggpackage = "gg.wf.Block"
  @type = "block"

  compute: (datas, params) -> datas

  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    pstore = @pstore()

    [flat, paths] = gg.wf.Inputs.flatten @inputs[0]
    newdatas = @compute flat, params

    # Write provenance
    pstore = @pstore()
    id2path = _.o2map flat, (data, idx) -> [data.id, paths[idx]]
    for data, idx in newdatas
      if data.id of id2path
        pstore.writeData [idx], id2path[data.id]
      else
        pstore.writeData [idx], null

    @output 0, newdatas



