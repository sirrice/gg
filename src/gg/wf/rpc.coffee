#<< gg/wf/node


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
    table = data.table
    env = data.env

    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    removedEls =
      svg: env.get('svg')
    env.rm('svg')

    tableJson = table.toJSON()
    envJson = env.toJSON()
    paramsJSON = @params.toJSON()

    env2 = gg.wf.Env.fromJSON envJson
    console.log env
    console.log envJson

    payload =
      table: tableJson
      env: envJson
      params: paramsJSON

    proto = "http:"
    hostname = "localhost"
    port = 8000
    socket = io.connect "#{proto}//#{hostname}:#{port}"

    socket.on "connect", () ->
      socket.emit "map", payload

    socket.on "result", (respData) =>
      console.log "got response"
      console.log respData.table
      table = gg.data.RowTable.fromJSON respData.table
      newenv = gg.wf.Env.fromJSON respData.env
      newenv.merge removedEls

      # add removed elements back
      @output 0, new gg.wf.Data(table, newenv)
      socket.disconnect()


