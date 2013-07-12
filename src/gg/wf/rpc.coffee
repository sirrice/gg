#<< gg/wf/node
#<< gg/wf/barrier


###
Send
  payload: payload
  inputSchema:
  outputSchema
  defaults
  compute
  nodewfmetadata
###

class gg.wf.RPC extends events.EventEmitter
  @ggpackage = "gg.wf.Flow"
  @id: -> gg.wf.RPC::_id += 1
  _id: 0

  @checkConnection: (uri, cb, errcb) ->
    responded = no

    socket = io.connect uri
    connected = socket.socket.connected
   
    onConnect = () ->
      unless responded
        responded = yes
        cb()
      socket.removeListener "connect", onConnect

    onFail = () ->
      unless responded
        responded = yes
        errcb()
      socket.removeListener "error", onFail
 
    socket.on "connect", onConnect
    socket.on "error", onFail

    if connected
      onConnect()
 
  constructor: (@spec) ->
    @id = gg.wf.RPC.id()
    @callid = 0
    @ready = no
    @nonce2cb = {}
    @buffer = []
    @params = new gg.util.Params @spec.params
    @log = gg.util.Log.logger "rpc"

    @setup()

  setup: ->
    uri = @params.get("uri") or "http://localhost:8000"
    @socket = io.connect uri
    @ready = @socket.socket.connected

    @socket.on "connect", () =>
      @ready = yes
      @flushBuffer()

    @socket.on "disconnect", () =>
      @ready = no

    callback = (respData) =>
      @log "recieved response for nonce #{respData.nonce}"
      nonce = respData.nonce
      if nonce? and nonce of @nonce2cb
        cb = @nonce2cb[nonce]
        delete @nonce2cb[nonce]
        cb respData


    @socket.on "register", callback
    @socket.on "deregister", callback
    @socket.on "runflow", callback

  flushBuffer: ->
    # XXX: This is not thread safe
    while @buffer.length > 0
      break unless @ready
      [command, payload, cb] = @buffer.shift()
      nonce = @callid
      @callid += 1
      payload = {} unless payload?
      payload.nonce = nonce
      @nonce2cb[nonce] = cb if _.isFunction cb
      @log "sending #{command} nonce: #{nonce}"
      @socket.emit command, payload

  send: (command, payload, cb) ->
    @buffer.push [command, payload, cb]
    @flushBuffer()

  register: (flow, cb) ->
    payload =
      flow : flow.toJSON()
      flowid: flow.id

    @send "register", payload, (respData) =>
      unless respData.status is "OK"
        @log "warning: flow registration failed"
      cb respData.status if _.isFunction cb
      @emit "register", respData.status

  deregister: (flow, cb) ->
    payload =
      flowid: flow.id

    @send "deregister", payload, (respData) =>
      unless respData.status is "OK"
        @log "warning: flow deregistration failed"
      cb respData.status if _.isFunction cb
      @emit "deregister", respData.status



  run: (flowid, nodeid, outport, inputs, cb) ->
    [inputsJson, removedEls] = gg.wf.rpc.Util.serialize inputs

    payload =
      flowid: flowid
      nodeid: nodeid
      outport: outport
      inputs: inputsJson

    @send "runflow", payload, (respData) =>
      nodeid = respData.nodeid
      outport = respData.outport
      outputs = gg.wf.rpc.Util.deserialize(
        respData.outputs, removedEls)

      cb nodeid, outport, outputs if _.isFunction cb
      @emit "runflow", nodeid, outport, outputs



