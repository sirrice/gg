#<< gg/wf/node


# Creates a clone of its inputs for each child
#
# NOTE: ONLY workflow node with multiple children
#
class gg.wf.Multicast extends gg.wf.Node
  @ggpackage = "gg.wf.Multicast"
  @type = "multicast"


  run: ->
    throw Error("Node not ready") unless @ready()

    inputs = @inputs[0]
    pstore = @pstore()
    outputs  = _.times @nChildren, (idx) =>
      f = 
        if idx < @nChildren
          (data) => 
            @log "cloning data #{data}"
            data.clone()
        else
          (data) -> data

      cb = (data, inpath) ->
        # write provenance
        outpath = _.clone inpath
        outpath.unshift idx
        inpath.unshift 0
        pstore.writeData outpath, inpath

        f data
      gg.wf.Inputs.mapLeaves inputs, cb

    for output, idx in outputs
      @output idx, output
    outputs

