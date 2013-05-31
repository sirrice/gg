express = require('express')
io = require('socket.io')
http = require('http')
app = express()

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

socket.configure 'development', () ->
  socket.set('log level', 3)

server.listen(8000)

socket.on 'connection', (client) ->

  client.on 'noop', (payload) ->
    client.emit "result", payload

  client.on 'disconnect', () ->
