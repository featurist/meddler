proxy = require '../src/proxy'
http = require 'http'
httpism = require 'httpism'
stream = require 'stream'
Transform = stream.Transform

describe 'middleware'
    
    remote server = http.create server @(req, res)
        res.end "I am remote"
    
    teapot middleware (inner) = {
        request (options, callback) =
            inner.request (options) @(response)
                teapot response = @new (Transform)
                teapot response._transform (chunk, encoding, callback) =
                    this.push (chunk.to string().replace('remote', 'a teapot'))
                    callback ()
                    
                teapot response.status code = 418
                response.pipe(teapot response)
                response.status code = 418
                callback (teapot response)
    }
    
    proxy server = proxy.create server (middleware: [teapot middleware])
    
    before
        remote server.listen 8555
        proxy server.listen 8666
    
    after
        remote server.close()
        proxy server.close()
    
    get using the proxy (proxy) =
        httpism.get! "http://127.0.0.1:8555" { proxy = "http://127.0.0.1:8666" }
    
    it 'can rewrite status codes'
        response = get using the proxy!
        response.status code.should.equal 418
    
    it 'can rewrite content'
        response = get using the proxy!
        response.body.should.equal 'I am a teapot'
        
