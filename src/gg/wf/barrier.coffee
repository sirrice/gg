#<< gg/wf/node

#
# The nested structure of the data objects is preserved, but 
# temporarily flattens the @inputs for the @compute function
#
# @compute(tables) -> tables
# The compute function takes a list of N tables and outputs N tables
# such that the positions of the input and output tables match up
#
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"


  compute: (datas, params) -> datas

  run: ->
    throw Error("Node not ready") unless @ready()

    [flat, md] = gg.wf.Inputs.flatten @inputs
    datas = @compute flat, @params
    outputs = gg.wf.Inputs.unflatten datas, md

    # XXX: Write provenance.  assume input and output datas 
    #      1) are the same (number and ids)
    #      2) retain the same path
    # XXX: Alternative -- @compute writes provenance
    pstore = @pstore()
    gg.wf.Inputs.mapLeaves @inputs, (data, path) ->
      pstore.writeData path, path

    for output, idx in outputs
      @output idx, output
    outputs

