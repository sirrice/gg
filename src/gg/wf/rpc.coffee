#<< gg/wf/node

io = require "socket.io-client"

class gg.wf.RPC extends gg.wf.Node
  constructor: (@spec={}) ->
    super

  run: ->
    # create message
    # send message
    # wait for response
    #  emit outputs
    #  XXX: ensure that flow Runner makes progress through event handlers and not synchronous calls.  Use some library to manage?

    throw Error("node not ready") unless @ready()

    data = @inputs[0]
    dataJson = data.table.toJSON()
    envJson = data.env.toJSON()

    payload =
      data: dataJson
      env: envJson

    proto = "http:"
    hostname = "localhost"
    port = 8000
    socket = io.connect "#{proto}//#{hostname}:#{port}"

    socket.on "connect", () ->
      socket.emit "noop", payload

    socket.on "result", (respData) =>
      console.log "got response"
      console.log respData.data
      table = gg.data.RowTable.fromJSON respData.data
      newenv = gg.wf.Env.fromJSON respData.env
      @output 0, new gg.wf.Data(table, newenv)
      socket.disconnect()

