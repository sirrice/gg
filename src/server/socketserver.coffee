express = require 'express'
io = require 'socket.io'
http = require 'http'
globals = require '../../globals'
gg = require '../../ggplotjs2'
us = require 'underscore'
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

  # Exec
  client.on 'compute', (payload) ->
    console.log "COMPUTE"
    table = gg.data.RowTable.fromJSON payload.table
    env = gg.wf.Env.fromJSON payload.env
    params = gg.util.Params.fromJSON payload.params
    klassname = params.get 'klassname'

    console.log "table:"
    console.log table

    console.log params

    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: 'tmp'
      params: params
    }

    restable = o.compute table, env, params


    payload =
      table: restable.toJSON()
      env: env.toJSON()
    client.emit "result", payload

  # Barrier
  client.on 'computeBarrier', (payload) ->
    console.log "COMPUTEBARRIER"
    tables = us.map payload.tables, (json) ->
      gg.data.RowTable.fromJSON json
    envs = us.map payload.envs, (json) ->
      gg.wf.Env.fromJSON json
    params = gg.util.Params.fromJSON payload.params
    klassname = params.get 'klassname'

    klass = gg.util.Util.ggklass klassname
    o = new klass {
      name: 'tmp'
      params: params
    }

    restables = o.compute tables, envs, params


    tableJSONs = us.map restables, (t) -> t.toJSON()
    envJSONs = us.map envs, (env) -> env.toJSON()
    payload =
      tables: tableJSONs
      envs: envJSONs

    client.emit "result", payload


  client.on 'disconnect', () ->
