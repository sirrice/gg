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

  compute: (data, params) -> data

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    pstore = @pstore()
    f = (data, path) =>
      pstore.writeData path, path
      @compute data, params

    outputs = gg.wf.Inputs.mapLeaves @inputs, f
    for output, idx in outputs
      @output idx, output
    outputs

  @create: (params, compute) ->
    new gg.wf.Exec
      params: params
      f: compute





