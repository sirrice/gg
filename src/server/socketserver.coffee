express = require 'express'
io = require 'socket.io'
http = require 'http'
globals = require '../../test/globals'
gg = require '../../lib/gg-server'
us = require 'underscore'
_ = require 'underscore'
app = express()
$ = require 'jQuery'

app.configure () ->
  app.use (req, res, next) ->
      res.removeHeader("X-Powered-By")
      next()
  app.use(express.static(__dirname + '/static'))

server = http.createServer(app)
socket = io.listen(server)

socket.set('browser client', false)

socket.configure 'production',  () ->
  socket.enable('browser client etag')
  socket.set('log level', 1)

###
socket.configure 'development', () ->
  socket.set('log level', 3)
###

server.listen(8000)

socket.on 'connection', (client) ->
  flows = {}
  runners = {}
  nonces = {} # [nodeid, outport] -> nonce

  lookupAndRmNonce = (flow, outnodeid, outport) ->
    # step backward in flow until find
    outnode = flow.nodeFromId outnodeid

    # go from node's outport to inpont
    if outnode.type == "barrier"
      inport = outport
    else
      inport = 0

    ps = flow.portGraph.parents {n: outnode, p: inport}
    if ps.length > 1
      throw Error("#{outnode.name}:inport(#{inport})
                  has #{ps.length} parents")
    if ps.length == 0
      return null

    parent = ps[0].n
    port = ps[0].p
    if [parent.id, port] of nonces
      nonce = nonces[[parent.id, port]]
      delete nonces[[parent.id, port]]
      return nonce
    return lookupAndRmNonce flow, parent.id, port


  client.on 'noop', (payload) ->
    client.emit "result", payload

  client.on "register", (payload) ->
    flowid = payload.flowid
    flow = gg.wf.Flow.fromJSON payload.flow
    nonce = payload.nonce
    flow.instantiate()
    console.log flow.toString()

    sendback = (nodeid, outport, outputs) ->
      # lookup something for the correct nonce
      nonce = lookupAndRmNonce flow, nodeid, outport
      unless nonce?
        console.log "#{nodeid}:port#{outport}
        Couldn't find a nonce!!"
      console.log outputs
      console.log "emit to client nonce: #{nonce}"
      client.emit "runflow",
        nodeid: nodeid
        outport: outport
        nonce: nonce
        outputs: gg.wf.rpc.Util.serialize(outputs)[0]

    runner = new gg.wf.Runner flow, sendback

    flows[flowid] = flow
    runners[flowid] = runner

    client.emit "register",
      nonce: nonce
      status: "OK"


  client.on "runflow", (payload) ->
    # flowid of the master flow
    flowid = payload.flowid
    nodeid = payload.nodeid
    outport = payload.outport
    console.log payload.inputs
    inputs = gg.wf.rpc.Util.deserialize payload.inputs
    nonce = payload.nonce
    nonces[[nodeid, outport]] = nonce

    flat = gg.wf.Inputs.flatten(inputs)[0]
    env = _.first(flat).env
    if env? and env.contains("scales")
      console.log "scales for node #{nodeid} nonce #{nonce}"
      console.log env.get('scales').toString()


    flow = flows[flowid]
    runner = runners[flowid]
    node = flow.nodeFromId nodeid
    console.log "runflow called: flow #{flowid}, node #{node.name} id #{nodeid}, port: #{outport}"
    runner.ch.routeNodeResult nodeid, outport, inputs


  client.on 'disconnect', () ->
