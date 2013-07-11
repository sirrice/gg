#<< gg/wf/node

#
# @compute(tables) -> tables
# The compute function takes a list of N tables and outputs N tables
# such that the positions of the input and output tables match up
#
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"


  compute: (tables, env, params) -> tables

  run: ->
    throw Error("Node not ready") unless @ready()

    # prepare inputs for compute function
    [flat, md] = gg.wf.Inputs.flatten @inputs
    tables = _.map flat, (d) -> d.table
    envs = _.map flat, (d) -> d.env

    # Execute compute function
    # XXX: it's the @compute() job to call @pstore().writeData
    tables = @compute tables, envs, @params

    # XXX: assume it's exact mapping
    pstore = @pstore()
    gg.wf.Inputs.mapLeaves @inputs, (data, path) ->
      pstore.writeData path, path

    # reconstruct original inputs structure
    datas = _.times tables.length, (idx) ->
      new gg.wf.Data tables[idx], envs[idx]
    outputs = gg.wf.Inputs.unflatten datas, md

    _.each outputs, (output, idx) => @output idx, output
    outputs

