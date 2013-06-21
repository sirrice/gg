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

RPCBase =
  #command: -> "compute"

  # @overridable
  #serialize: ->
  #  throw Error("serialize not implemented")

  # @overridable
  #deserialize: (respData) ->
  #  throw Error("deserialize not implemented")

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
    throw Error("node not ready") unless @ready()

    channelName = "result#{Math.random()}"
    payload = @serialize()
    payload.channelName = channelName

    proto = @params.get('proto') or "http:"
    hostname = @params.get('hostname') or "localhost"
    port = @params.get('port') or 8000
    socket = io.connect "#{proto}//#{hostname}:#{port}"
    command = @command()

    console.log payload

    # XXX: race condition.
    if socket.socket.connected
      socket.emit command, payload
    else
      socket.on "connect", () ->
        socket.removeAllListeners "connect"
        socket.emit command, payload

    socket.on channelName, (respData) =>
      socket.removeAllListeners channelName
      console.log respData

      @deserialize respData


# Single input
class gg.wf.RPC extends gg.wf.Node
  @ggpackage = "gg.wf.RPC"

  command: -> "compute"

  serialize: ->
    data = @inputs[0]
    [payload, @removedEls] = gg.wf.rpc.Util.serializeOne(
      data.table
      data.env
      @params)
    payload.name = @name
    payload

  deserialize: (respData) ->
    [table, env] = gg.wf.rpc.Util.deserializeOne(
      respData, @removedEls)

    @output 0, new gg.wf.Data(table, env)
_.extend gg.wf.RPC::, RPCBase

# Multiple table inputs
class gg.wf.RPCBarrier extends gg.wf.Barrier
  @ggpackage = "gg.wf.RPCBarrier"

  command: -> "barrier"

  serialize: ->
    [payload, @removedEls] = gg.wf.rpc.Util.serializeMany(
      _.map @inputs, (data) -> data.table
      _.map @inputs, (data) -> data.env
      @params)
    payload.name = @name
    payload

  deserialize: (respData) ->
    [tables, envs] = gg.wf.rpc.Util.deserializeMany(
      respData, @removedEls)

    for i in [0...tables.length]
      @output i, new gg.wf.Data(tables[i], envs[i])
_.extend gg.wf.RPCBarrier::, RPCBase



# No inputs
class gg.wf.RPCSource extends gg.wf.Source
  @ggpackage = "gg.wf.RPCSource"

  command: -> "source"

  serialize: ->
    payload = {
      params: @params.toJSON()
    }
    payload.name = @name
    payload

  deserialize: (respData) ->
    table = gg.data.RowTable.fromJSON respData.table
    env = gg.wf.Env.fromJSON respData.env


    @output 0, new gg.wf.Data(table, env)
_.extend gg.wf.RPCSource::, RPCBase


class gg.wf.RPCSplit extends gg.wf.Split
  @ggpackage = "gg.wf.RPCSource"

  command: -> "split"

  serialize: ->
    [payload, @removedEls] = gg.wf.rpc.Util.serializeOne(
      @inputs[0].table
      @inputs[0].env
      @params)

    payload.name = @name
    payload

  deserialize: (respData) ->
    [tables, envs] = gg.wf.rpc.Util.deserializeMany(
      respData, @removedEls)

    @allocateChildren tables.length

    _.times tables.length, (idx) =>
      data = new gg.wf.Data(tables[idx], envs[idx])
      @output idx, data
    tables
_.extend gg.wf.RPCSplit::, RPCBase


class gg.wf.RPCJoin extends gg.wf.Join
  @ggpackage = "gg.wf.RPCSource"

  command: -> "split"

  serialize: ->
    [payload, @removedEls] = gg.wf.rpc.Util.serializeMany(
      _.map @inputs, (data) -> data.table
      _.map @inputs, (data) -> data.env
      @params)
    payload.name = @name
    payload

  deserialize: (respData) ->
    [table, env] = gg.wf.rpc.Util.deserializeOne(
      respData, @removedEls)

    @output 0, new gg.wf.Data(table, env)
_.extend gg.wf.RPCJoin::, RPCBase
