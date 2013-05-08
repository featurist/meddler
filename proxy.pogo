http = require 'http'
url utils = require 'url'
Memory Stream = require 'memorystream'

create memory stream () = new (Memory Stream (null, readable: false))

forward request (request, response, url: nil, method: 'GET', headers: {}) =
    parsed url = url utils.parse (url) 
    port = parsed url.port
    host = parsed url.hostname
    path = parsed url.path || '/'
    protocol = parsed url.protocol.replace r/:$/ ''
    proxy request options = { host = host, port = port, method = method, path = path, headers = headers }
    
    proxy request = http.request (proxy request options) @(proxy response)
        proxy response.pipe (response)
        proxy response.on 'end'
            response.end()

        response.write head (proxy response.status code, proxy response.headers)

    request.pipe (proxy request)

    proxy request.on 'error' @(error)
        response.end()

exports.create server() =
    
    authenticate request (request, response) then (respond) =
        header = request.headers.'proxy-authorization' || ''
        token = header.split(r/\s+/).pop() || ''
        auth = @new Buffer(token, 'base64').to string()
        parts = auth.split(r/:/)
        username = parts.0
        password = parts.1
        
        if ((username == 'featurist') && (password == 'cats'))        
            respond()
        else
            response.write head (407, 'Proxy-Authenticate': 'Basic realm="Please enter your account details to continue"')
            response.end "Please enter your account details to continue"
    
    http.create server @(request, response)
        authenticate request (request, response) then
            if (request.url.match (r/^http/))
                forward request (
                    request
                    response
                    url: request.url
                    method: request.method
                    headers: request.headers
                )
            else
                response.end "Coming soon!"
