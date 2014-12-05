require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery/jquery'
    # binaryjs: 'vendor/binaryjs/server'
    # binaryjs: 'http://cdn.binaryjs.com/0/binary.js'
  , [
    # 'app/example-view'
    # 'binaryjs'
  ]
  , (
    # ExampleView
    # BC
  ) ->
    # view = new ExampleView()
    # view.render('body')
    
    # Connect to Binary.js server
    client = new BinaryClient('ws://localhost:9000')
    # Received new stream from server!
    client.on('stream', (stream, meta)->
      console.log 'stream'
      # Buffer for parts
      parts = []
      # Got new data
      stream.on('data', (data)->
        parts.push(data)
      )
      stream.on('end', ()->
        # Display new data in browser!
        img = document.createElement("img")
        img.src = (window.URL or window.webkitURL).createObjectURL(new Blob(parts))
        document.body.appendChild(img)
      )
    )