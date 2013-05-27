Event Emitter = require 'events'.Event Emitter
http = require 'http'
url = require 'url'

exports.create server (middleware: []) =
    requester = chain (middleware) together
    http.create server @(request, response)
        if (request.url.match (r/^http/))
            forward request (requester, request, response)
        else
            response.end "this is not a website"

exports.end response (status, body, callback) =
    response = @new (Event Emitter)
    response.status code = status
    response.pipe (r) = r.end (body)
    response.end () = true
    callback (response)
    response.emit 'end'
    response

chain (middleware) together =
    requester = http
    for each @(wrapper) in (middleware)
        requester := wrapper (requester)

    requester

forward request (http, request, response) =
    options = forwarding options for (request)
    proxy request = http.request (options) @(res)
        res.pipe (response)
        res.on 'end' @{ response.end() }
        response.write head (res.status code, res.headers)

    request.pipe (proxy request)
    proxy request.on 'error' @(error)
        response.end()

forwarding options for (request) =
    parsed url = url.parse (request.url)
    {
        host = parsed url.hostname
        port = parsed url.port
        method = request.method
        path = parsed url.path || '/'
        headers = request.headers
    }

