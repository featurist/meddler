proxy = require './proxy'
auth = require './auth'

port = process.env.PORT || 3000

middleware = [ auth.for users { featurist = 'cats' } ]
proxy.create server( middleware: middleware ).listen(port)
console.log "http://127.0.0.1:#(port)"