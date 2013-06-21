express = require 'express'
io = require 'socket.io'
http = require 'http'
globals = require '../../globals'
gg = require '../../ggplotjs2'
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

  client.on 'noop', (payload) ->
    client.emit "result", payload

  # Source 0 -> 1
  client.on 'source', (payload) ->
    channel = payload.channelName
    env = new gg.wf.Env()

    params = gg.util.Params.fromJSON payload.params
    klassname = params.get 'klassname'
    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: payload.name or 'tmp'
      params: params
    }

    restable = o.compute null, env, params


    [payload, skip] = gg.wf.rpc.Util.serializeOne restable, env
    console.log "source returning to client on channel #{channel}"
    client.emit channel, payload


  # Exec 1 -> 1
  client.on 'compute', (payload) ->
    channel = payload.channelName
    [table, env] = gg.wf.rpc.Util.deserializeOne(payload)
    params = gg.util.Params.fromJSON payload.params

    klassname = params.get 'klassname'
    name = payload.name or 'tmp'
    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: name
      params: params
    }

    restable = o.compute table, env, params

    [payload, skip] = gg.wf.rpc.Util.serializeOne restable, env
    payload.name = name
    console.log "exec #{name} returning to client on channel #{channel}"
    client.emit channel, payload


  # Split 1 -> N
  client.on 'split', (payload) ->
    channel = payload.channelName
    [table, env] = gg.wf.rpc.Util.deserializeOne(payload)
    params = gg.util.Params.fromJSON payload.params

    klassname = params.get 'klassname'
    name = payload.name or 'tmp'
    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: payload.name or 'split'
      params: params
    }

    o.addInputPort()
    o.getAddInputCB(0)(null, new gg.wf.Data(table, env))
    datas = o.run()

    [payload, skip] = gg.wf.rpc.Util.serializeMany(
      _.map(datas, (data) -> data.table)
      _.map(datas, (data) -> data.env))
    payload.name = name
    console.log "split #{name} returning to client on channel #{channel}"
    client.emit channel, payload

  # Join N -> 1
  client.on 'join', (payload) ->
    channel = payload.channelName
    [tables, envs] = gg.wf.rpc.Util.deserializeMany(payload)
    params = gg.util.Params.fromJSON payload.params

    klassname = params.get 'klassname'
    name = payload.name or 'tmp'
    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: payload.name or 'tmp'
      params: params
    }

    restable = o.compute tables, envs, params
    env = _.first(envs)

    [payload, skip] = gg.wf.rpc.Util.serializeOne restable, env
    payload.name = name
    console.log "join #{name} returning to client on channel #{channel}"
    client.emit channel, payload



  # Barrier N -> N
  client.on 'barrier', (payload) ->
    channel = payload.channelName
    [tables, envs] = gg.wf.rpc.Util.deserializeMany(payload)
    params = gg.util.Params.fromJSON payload.params

    klassname = params.get 'klassname'
    name = payload.name or 'tmp'
    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: payload.name or 'tmp'
      params: params
    }

    console.log params
    restables = o.compute tables, envs, params

    [payload, skip] = gg.wf.rpc.Util.serializeMany restables, envs
    payload.name = name
    console.log "barrier #{name} returning to client on channel #{channel}"
    client.emit channel, payload


  client.on 'disconnect', () ->
