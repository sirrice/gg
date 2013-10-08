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

  compute: (tableset, params, cb) -> cb(null, tableset)

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
    done = (err, partitions) =>

    async.map partitions, iterator, (err, pairtables) =>
      throw Error err if err?
      result = new gg.data.MultiTable null, pairtables
      @output 0, result





  @create: (params, compute) ->
    class ExecKlass extends gg.wf.Exec
      compute: compute
    new ExecKlass
      params: params





