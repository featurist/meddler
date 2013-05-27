proxy = require '../src/proxy'

port = process.env.PORT || 3000

block ads (inner) = {
    request (options, callback) =
        if (is advertiser (options))
            proxy.end response 404 'not found' (callback)
        else
            inner.request (options, callback)
}

is advertiser (options) =
    (options.host + ' ' + options.path).index of 'doubleclick' > -1

proxy.create server ( middleware: [ block ads ] ).listen(port)
console.log "http://127.0.0.1:#(port)"