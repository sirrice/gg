#<< gg/wf/node

#
# Multiinput -> tableset -> compute -> tableset -> multioutput
#
# Adds a hidden column (_barrier) to the data to track input and output ports
# 
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"

  compute: (tableset, params, cb) -> cb null, tableset

  run: ->
    throw Error("Node not ready") unless @ready()

    pairtables = _.map @inputs, (pt, idx) ->
      t = pt.getTable()
      t = t.addConstColumn '_barrier', idx
      md = pt.getMD()
      md = md.addConstColumn '_barrier', idx
      new gg.data.PairTable t, md

    tableset = new gg.data.TableSet pairtables
    @compute tableset, @params, (err, tableset) =>
      ps = gg.data.Transform.partitionJoin tableset.getTable(), tableset.getMD(), '_barrier'
      for p in ps
        idx = p['key']
        result = p['table']
        t = result.getTable().rmColumn '_barrier'
        console.log t
        result = new gg.data.PairTable t, result.getMD()
        @output idx, result

        
  @create: (params, f) ->
    params ?= {}
    class Klass extends gg.wf.Barrier
      compute: (args...) -> f args...
    new Klass 
      params: params
