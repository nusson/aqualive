BinaryServer = require('binaryjs').BinaryServer
fs = require('fs')

# Start Binary.js server
server = BinaryServer
  port: 9000

# Wait for new user connections
server.on('connection', (client)->
  console.log __dirname + '/stream/flower.png'
  # Stream a flower as a hello!
  file = fs.createReadStream(__dirname + '/public/stream/flower.png')
  client.send(file) 
)

