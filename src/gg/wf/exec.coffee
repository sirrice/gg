#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  @ggpackage = "gg.wf.Exec"
  @type = "exec"

  parseSpec: ->
    @params.ensure 'compute', ['f'], null

  compute: (table, env, params) -> table

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    pstore = @pstore()
    f = (data, path) =>
      table = @compute data.table, data.env, params
      data = new gg.wf.Data table, data.env

      pstore.writeData path, path

      data

    outputs = gg.wf.Inputs.mapLeaves @inputs, f
    for output, idx in outputs
      @output idx, output
    outputs

  @create: (params, compute) ->
    new gg.wf.Exec
      params: params
      f: compute





