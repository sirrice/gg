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
    compute = @params.get('compute') or @compute.bind(@)
    pstore = @pstore()
    f = (data, path) =>
      pstore.writeData path, path
      compute data, params

    outputs = gg.wf.Inputs.mapLeaves @inputs, f
    gg.wf.Inputs.mapLeaves outputs, (data) -> gg.wf.Stdout.print data.table, null, 5
    for output, idx in outputs
      @output idx, output
    outputs

  @create: (params, compute) ->
    class ExecKlass extends gg.wf.Exec
      compute: compute
    new ExecKlass
      params: params





