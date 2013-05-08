http = require 'http'
url utils = require 'url'

handlers = {
    
    create proxy request (exchange, callback) =
        parsed url = url utils.parse (exchange.client request.url) 
        exchange.proxy request options = {
            host    = parsed url.hostname
            port    = parsed url.port
            method  = exchange.client request.method
            path    = parsed url.path || '/'
            headers = exchange.client request.headers
        }
        callback (nil)
    
    send proxy request (exchange, callback) =
        exchange.proxy request = http.request (exchange.proxy request options) @(proxy response)
            exchange.proxy response = proxy response
            callback (nil)
        
        exchange.client request.pipe (exchange.proxy request)
    
    pipe response (exchange, callback) =
        exchange.proxy response.pipe (exchange.client response)
        exchange.proxy response.on 'end' @{ exchange.client response.end() }
        exchange.client response.write head (
            exchange.proxy response.status code
            exchange.proxy response.headers
        )
        callback (nil)

}

handle request (request, response) =
    
    exchange = {
        client request  = request
        client response = response
        proxy request   = nil
        proxy response  = nil
    }
    
    create proxy request () =
        handlers.create proxy request (exchange) @(create error)
            if (create error)
                failed to 'create proxy request' with (create error)
            else
                send proxy request ()
    
    send proxy request () =
        handlers.send proxy request (exchange) @(send error)
            if (send error)
                failed to 'send proxy request' with (send error)
            else
                pipe response ()
            
        exchange.proxy request.on 'error' @(proxy request error)
            failed to 'send proxy request' with (proxy request error)
    
    pipe response () =
        handlers.pipe response (exchange) @(pipe error)
            if (pipe error)
                failed to 'pipe response' with (pipe error)
    
    failed to (what) with (error) =
        message = "Failed to #(what): #(error.to string())"
        console.log (message)
        response.write head 502
        response.end (message)
    
    create proxy request ()
            

exports.create server() = http.create server (handle request)