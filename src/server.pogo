proxy = require './proxy'

proxy.create server().listen(3000)
console.log("http://127.0.0.1:3000")