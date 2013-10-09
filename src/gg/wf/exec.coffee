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

  compute: (pairtable, params, cb) -> cb null, pairtable

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    pstore = @pstore()

    tableset = new gg.data.TableSet @inputs
    partitions = tableset.partition @params.get('key')
    iterator = (pairtable, cb) ->
      compute pairtable, params, cb
    async.map partitions, iterator, (err, pairtables) =>
      throw Error err if err?
      result = new gg.data.TableSet pairtables
      @output 0, result


  @create: (params=null, compute) ->
    params ?= new gg.util.Params
    class Klass extends gg.wf.Exec
      compute: (pairtable, params, cb) ->
        compute pairtable, params, cb
    new Klass
      params: params





