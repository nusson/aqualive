express       = require 'express'
engines       = require 'consolidate'
routes        = require './routes'
BinaryServer  = require('binaryjs').BinaryServer
fs            = require 'fs'
util          = require 'util'



exports.startServer = (config, callback) ->

  port = process.env.PORT or config.server.port

  app = express()

  ###* @type {Number} interval (ms) to resend file ###
  @delay      = 5000
  @dir        = __dirname + '/public/stream/'
  @filename   = null

  setInterval(getLastFile.bind(@), @delay)


  # server = http.createServer(app)
  
  server = app.listen port, ->
    console.log "Express server listening on port %d in %s mode", server.address().port, app.settings.env

  # server.on('connection', (client)->
  #   console.log('dirname, client')
  #   file = fs.createReadStream(@dirname + '/flower.png')
  #   client.send(file)
  #   # stream = client.createStream()
  #   # file.pipe(stream)
  # )
  bs = BinaryServer
    port: 9000
  #   
  # bs = BinaryServer
  #   server: server

  bs.on('connection', (client)=>

    fs.exists(@dir, (exists)=>
      if exists
        sendFile.bind(@)(client)
        client.interval = setInterval(sendFile.bind(@, client), @delay)
    )

    # console.log 'connection'

    # // Incoming stream from browsers
    # client.on('stream', function(stream, meta){

    #   // broadcast to all other clients
    #   for id in bs.clients
    #     if bs.clients.hasOwnProperty(id)
    #       otherClient = bs.clients[id]
    #       if otherClient != client
    #         send = otherClient.createStream(meta)
    #         stream.pipe(send)
    # )
  )
  # @todo stop when client off
  
  app.configure ->
    app.set 'port', port
    app.set 'views', config.server.views.path
    app.engine config.server.views.extension, engines[config.server.views.compileWith]
    app.set 'view engine', config.server.views.extension
    app.use express.favicon()
    app.use express.urlencoded()
    app.use express.json()
    app.use express.methodOverride()
    app.use express.compress()
    app.use config.server.base, app.router
    app.use express.static(config.watch.compiledDir)

  app.configure 'development', ->
    app.use express.errorHandler()

  app.get '/', routes.index(config)
    



  # if fs.existsSync('D:/Games')
  #   console.log 'exists'

  # fs.exists('D:/Games', (exists)->
  #   console.log exists
  # )

  callback(server)


getLastFile = (client)->
  fs.readdir(@dir, (err, data)=>
    filename  = data.pop()

    if data.length > 0 and @filename? and @filename is filename
      console.log '- delette', @filename
      fs.unlinkSync(@dir+@filename)
      filename  = data.pop()


    @filename = filename

  )


sendFile  = (client)->
  if not @filename? then return
  
  if not client.lastfile? or client.lastfile isnt @filename
    file = fs.createReadStream(@dir+@filename);
    client.send(file)
    console.log '- send', @filename

  client.lastfile = @filename