#<< gg/util/graph

class gg.prov.PStore extends gg.util.Graph
  @pstores = {}  # flow id -> op.id -> pstore instance

  # @param flowid id of gg.wf.Flow instance
  # @param opid id of operator specific provstore.  
  #             null to fetch workflow level port->port pstore
  @get: (flow, op=null) ->
    flowid = flow.id
    @pstores[flowid] = new gg.prov.PStore flow unless flowid of @pstores

    if op?
      @pstores[flowid].get op
    else
      @pstores[flowid]


  constructor: (@flow) ->
    super()
    @opstores = {}
    @id (o) -> JSON.stringify o

  get: (op) ->
    unless op.id of @opstores
      @opstores[op.id] = new gg.prov.OPStore @flow, op 
    @opstores[op.id]

  query: (query) ->


