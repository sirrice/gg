#<< gg/wf/node

#
# Multiinput -> tableset -> compute -> tableset -> multioutput
#
# Adds a hidden column (_barrier) to the data to track input and output ports
#
# 
class gg.wf.Barrier extends gg.wf.Node
  @ggpackage = "gg.wf.Barrier"
  @type = "barrier"

  compute: (pt, params, cb) -> cb null, pt

  run: ->
    throw Error("Node not ready") unless @ready()
    compute = @params.get('compute') or @compute.bind(@)

    tables = _.map @inputs, (pt, idx) ->
      t = pt.left()
      t.setColVal '_barrier', idx
    mds = _.map @inputs, (pt, idx) ->
      md = pt.right()
      md.setColVal '_barrier', idx

    table = new data.ops.Union tables
    md = new data.ops.Union mds
    tableset = new data.PairTable table, md

    compute tableset, @params, (err, tableset) =>
      throw err if err?
      table = tableset.left()
      md = tableset.right()
      table = table.partition '_barrier', 'table'
      md = md.partition '_barrier', 'md'
      console.log md.raw()

      pairtable = table.join md, '_barrier' # schema: table, md, _barrier
      pairtable.each (row) =>
        table = row.get('table')
        md = row.get('md') or null
        table = table.exclude('_barrier') if table?
        md = md.exclude('_barrier') if md?
        idx = row.get '_barrier'
        console.log "outputing with md.nrows = #{md.nrows()}" if md?
        @output idx, new data.PairTable(table, md)
        

class gg.wf.SyncBarrier extends gg.wf.Barrier
  parseSpec: ->
    super
    f = @params.get 'compute'
    f ?= @compute.bind @
    name = @name
    makecompute = (f) ->
      (pairtable, params, cb) ->
        try
          res = f pairtable, params, () ->
            throw Error "SyncBarrier should not call callback"
          cb null, res
        catch err
          console.log "err in SyncBarrier #{name}"
          console.log err.toString()
          cb err, null
    @params.put 'compute', makecompute(f)
        

