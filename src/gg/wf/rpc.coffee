#<< gg/wf/node
#<< gg/wf/barrier


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

    payload =
      table: tableJson
      env: envJson
      params: paramsJSON

    proto = "http:"
    hostname = "localhost"
    port = 8000
    socket = io.connect "#{proto}//#{hostname}:#{port}"

    socket.on "connect", () ->
      socket.emit "compute", payload

    socket.on "result", (respData) =>
      console.log "got response"
      console.log respData.table
      table = gg.data.RowTable.fromJSON respData.table
      newenv = gg.wf.Env.fromJSON respData.env
      newenv.merge removedEls

      # add removed elements back
      @output 0, new gg.wf.Data(table, newenv)
      socket.disconnect()

class gg.wf.RPCBarrier extends gg.wf.Barrier
  constructor: (@spec={}) ->
    super

  run: ->
    # create message
    # send message
    # wait for response
    #  emit outputs
    #  XXX: ensure that flow Runner makes progress through event handlers and not synchronous calls.  Use some library to manage?

    throw Error("node not ready") unless @ready()


    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    removedEls =
      _.map @inputs, (data) ->
        {svg: data.env.rm('svg')}

    tableJSONs = _.map @inputs, (data) -> data.table.toJSON()
    envJSONs = _.map @inputs, (data) -> data.env.toJSON()
    paramsJSON = @params.toJSON()

    payload =
      tables: tableJSONs
      envs: envJSONs
      params: paramsJSON

    console.log @inputs[0].env
    console.log JSON.stringify envJSONs[0].val.scalesconfig

    proto = "http:"
    hostname = "localhost"
    port = 8000
    socket = io.connect "#{proto}//#{hostname}:#{port}"

    socket.on "connect", () ->
      socket.emit "computeBarrier", payload

    socket.on "result", (respData) =>
      tables = _.map respData.tables, (json) ->
        gg.data.RowTable.fromJSON json

      envs = _.map respData.envs, (json, i) ->
        env = gg.wf.Env.fromJSON json
        env.merge removedEls[i]
        env

      console.log "got result"
      console.log respData.envs[0]

      for i in [0...tables.length]
        console.log "barrier rpc output: #{i}"
        @output i, new gg.wf.Data(tables[i], envs[i])
      socket.disconnect()


