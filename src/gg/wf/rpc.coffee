#<< gg/wf/node
#<< gg/wf/barrier


class gg.wf.RPC extends gg.wf.Node
  constructor: (@spec={}) ->
    super

    @params.ensureAll
      proto: [[], "http:"]
      hostname: [[], "localhost"]
      port: [[], 8000]

    proto = @params.get 'proto'
    hostname = @params.get 'hostname'
    port = @params.get 'port'

    @params.ensure 'uri', [], "#{proto}//#{hostname}:#{port}"

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
      svg: env.rm 'svg'

    tableJson = table.toJSON()
    envJson = env.toJSON()
    paramsJSON = @params.toJSON()

    payload =
      table: tableJson
      env: envJson
      params: paramsJSON


    socket = io.connect @params.get 'uri'

    if socket.socket.connected
      socket.emit "compute", payload
    else
      socket.on "connect", () ->
        socket.removeAllListeners "connect"
        socket.emit "compute", payload

    socket.on "result", (respData) =>
      socket.removeAllListeners "result"

      table = gg.data.RowTable.fromJSON respData.table
      newenv = gg.wf.Env.fromJSON respData.env
      newenv.merge removedEls

      @output 0, new gg.wf.Data(table, newenv)

class gg.wf.RPCBarrier extends gg.wf.Barrier
  constructor: (@spec={}) ->
    super

    @params.ensureAll
      proto: [[], "http:"]
      hostname: [[], "localhost"]
      port: [[], 8000]

    proto = @params.get 'proto'
    hostname = @params.get 'hostname'
    port = @params.get 'port'

    @params.ensure 'uri', [], "#{proto}//#{hostname}:#{port}"

  validateEnvs: ->
    valid = _.all @inputs, (data) ->
      env = data.env
      # ensure doesn't have an svg or function
      yes
    unless valid
      throw Error("environment was invalid")

  validateParams: ->
    # ensure doesn't have an svg or function
    valid = yes
    unless valid
      throw Error("params were invalid")


  run: ->
    # create message
    # send message
    # wait for response
    #  emit outputs
    #  XXX: ensure that flow Runner makes progress through event handlers and not synchronous calls.  Use some library to manage?

    throw Error("node not ready") unless @ready()


    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    # 2. reject environments/params that contain functions
    #    or do something smarter?
    removedEls =
      _.map @inputs, (data) ->
        {svg: data.env.rm('svg')}

    @validateEnvs()
    @validateParams()

    tableJSONs = _.map @inputs, (data) -> data.table.toJSON()
    envJSONs = _.map @inputs, (data) -> data.env.toJSON()
    paramsJSON = @params.toJSON()

    payload =
      tables: tableJSONs
      envs: envJSONs
      params: paramsJSON

    socket = io.connect @params.get 'uri'

    if socket.socket.connected
      socket.emit "computeBarrier", payload
    else
      socket.on "connect", () ->
        socket.removeAllListeners "connect"
        socket.emit "computeBarrier", payload

    socket.on "result", (respData) =>
      socket.removeAllListeners "result"

      tables = _.map respData.tables, (json) ->
        gg.data.RowTable.fromJSON json

      envs = _.map respData.envs, (json, i) ->
        env = gg.wf.Env.fromJSON json
        env.merge removedEls[i]

      for i in [0...tables.length]
        @output i, new gg.wf.Data(tables[i], envs[i])




