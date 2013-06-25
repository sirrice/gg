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

  constructor: (@spec) ->
    @id = gg.wf.RPC.id()
    @callid = 0
    @ready = no
    @nonce2cb = {}
    @buffer = []
    @params = new gg.util.Params @spec.params

    @setup()

  setup: ->
    uri = @params.get("uri") or "http://localhost:8000"
    @socket = io.connect uri
    @socket.on "connect", () =>
      @ready = yes
      @sendBuffer()

    @socket.on "disconnect", () =>
      @ready = no

    callback = (respData) =>
      nonce = respData.nonce
      if nonce? and nonce of @nonce2cb
        cb = @nonce2cb[nonce]
        delete @nonce2cb[nonce]
        cb respData


    @socket.on "register", callback
    @socket.on "runflow", callback

  sendBuffer: ->
    # XXX: This is not thread safe
    while @buffer.length > 0
      break unless @ready
      [command, payload, cb] = @buffer.shift()
      nonce = @callid
      @callid += 1
      payload = {} unless payload?
      payload.nonce = nonce
      @nonce2cb[nonce] = cb if _.isFunction cb
      console.log "sending #{command} nonce: #{nonce}"
      @socket.emit command, payload

  send: (command, payload, cb) ->
    @buffer.push [command, payload, cb]
    @sendBuffer()

  register: (flow, cb) ->
    payload =
      flow : flow.toJSON()
      flowid: flow.id

    @send "register", payload, (respData) =>
      unless respData.status is "OK"
        console.log "warning: flow registration failed"
      cb respData.status if _.isFunction cb
      @emit "register", respData.status


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
      console.log respData.outputs
      outputs = gg.wf.rpc.Util.deserialize(
        respData.outputs, removedEls)

      cb nodeid, outport, outputs if _.isFunction cb
      @emit "runflow", nodeid, outport, outputs



