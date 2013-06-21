#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  @ggpackage = "gg.wf.Exec"

  constructor: (@spec={}) ->
    super @spec
    @type = "exec"
    @name = _.findGood [@spec.name, "exec-#{@id}"]

    @params.ensure 'compute', ['f'], ((args...)=>@compute args...)

  compute: (table, env, node) -> table

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    data = @inputs[0]
    compute = @params.get 'compute'
    output = compute data.table, data.env, @params
    envclone = data.env.clone()
    if data.env.get('svg')? and not envclone.get('svg')?
      console.log _.keys(data.env.data)
      console.log _.keys(envclone.data)
      throw Error("clonig was not correct")
    data = new gg.wf.Data(output, envclone)
    @output 0, data
    output

  @create: (params, compute) ->
    new gg.wf.Exec
      params: params
      f: compute





