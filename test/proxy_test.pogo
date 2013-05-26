proxy = require '../src/proxy'
http = require 'http'
httpism = require 'httpism'

describe 'proxy'
    
    remote server = http.create server @(req, res)
        res.end "I am remote"
    
    proxy server = proxy.create server (middleware: [])
    
    before
        remote server.listen 8555
        proxy server.listen 8666
    
    after
        remote server.close()
        proxy server.close()
    
    get using the proxy (proxy) =
        httpism.get! "http://127.0.0.1:8555" { proxy = "http://127.0.0.1:8666" }
    
    it 'forwards HTTP requests'
        response = get using the proxy!
        response.status code.should.equal 200
        response.body.should.equal 'I am remote'

