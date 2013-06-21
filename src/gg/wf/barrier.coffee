#<< gg/wf/node

#
# @compute(tables) -> tables
# The compute function takes a list of N tables and outputs N tables
# such that the positions of the input and output tables match up
#
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"

  constructor: (@spec={}) ->
    super @spec
    @type = "barrier"
    @name = _.findGood [@spec.name, "barrier-#{@id}"]

    @params.ensure 'compute', ['f'], ((args...)=>@compute args...)

  compute: (tables, env, params) -> tables

  run: ->
    throw Error("Node not ready") unless @ready()


    # prepare inputs for compute function
    [flat, md] = gg.wf.Inputs.flatten @inputs
    tables = _.map flat, (d) -> d.table
    envs = _.map flat, (d) -> d.env
    console.log flat
    console.log md

    # Execute compute function
    @log.level = gg.util.Log.DEBUG
    @log "#{@name} running on #{tables.length} tables"
    @log tables
    @log @inputs
    compute = @params.get 'compute'
    tables = compute tables, envs, @params
    @log "#{@name} returned #{tables.length} tables"

    # reconstruct original inputs structure
    datas = _.times tables.length, (idx) ->
      new gg.wf.Data tables[idx], envs[idx]
    outputs = gg.wf.Inputs.unflatten datas, md

    @log outputs
    @log "#{@name} outputing #{outputs.length} outputs"
    _.each outputs, (output, idx) => @output idx, output
    outputs

