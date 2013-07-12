#<< gg/util/graph

class gg.prov.PStore extends gg.util.Graph
  @pstores = {}  # flow id -> op.id -> pstore instance

  # @param flowid id of gg.wf.Flow instance
  # @param opid id of operator specific provstore.  
  #             null to fetch workflow level port->port pstore
  @get: (flow, op=null) ->
    flowid = flow.id
    @pstores[flowid] = {} unless flowid of @pstores
    op2pstore = @pstores[flowid]
    opid = if op? then op.id else null
    unless opid of op2pstore
      pstore = new gg.prov.PStore flow, op
      # XXX: special cased for operator level pstore
      if opid?
        pstore.id (o) -> JSON.stringify o
      else
        pstore.id (o) -> "#{o.n.id}-#{o.p}" unless opid?
      op2pstore[opid] = pstore
    return op2pstore[opid]

  constructor: (@flow, @op) ->
    super()



  writeSchema: ->
  writePort: ->
  writeData: (outpath, inpath) ->
    @connect inpath, outpath, "data"

  writeSchemaAttr: ->


  toString: ->
    node2json = (node) -> JSON.stringify node
    edge2json = (from, to, type, md) ->
      "#{JSON.stringify from} (#{type})-> #{JSON.stringify to}"
    json = @toJSON node2json, edge2json
    links = json.links
    linkstr = _.map(links, (link) -> JSON.stringify link).join("\n\t")
    "#{@op.name}#{@op.id}:\t#{linkstr}"

