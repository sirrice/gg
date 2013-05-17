#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @compute = @spec.f or @compute
    @type = "exec"
    @name = _.findGood [@spec.name, "exec-#{@id}"]

  compute: (table, env, node) -> table


  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    data = @inputs[0]
    output = @compute data.table, data.env, @
    @output 0, new gg.wf.Data(output, data.env.clone())
    output



