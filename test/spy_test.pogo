proxy = require '../src/proxy'
spy = require '../src/spy'
http = require 'http'
httpism = require 'httpism'

describe 'spy'
    
    remote server = http.create server @(req, res)
        res.end "I am remote"
    
    events = []
    recorder = spy.create spy {
        
        requested () =
            events.push {
                name = 'requested'
                args = (arguments) as array
            }
        
        responded () =
            events.push {
                name = 'responded'
                args = (arguments) as array
            }
            
    }
    (args) as array = Array.prototype.slice.apply(args)
    
    proxy server = proxy.create server (middleware: [recorder])
    
    before
        remote server.listen 8555
        proxy server.listen 8666
    
    after
        remote server.close()
        proxy server.close()
    
    get (path) using the proxy (proxy) =
        httpism.get! "http://127.0.0.1:8555#(path)" {
            proxy = "http://127.0.0.1:8666"
        }
    
    it 'receives details of requests and responses'
        events := []
        get '/abc' using the proxy!
        get '/xyz' using the proxy!
        events.length.should.equal 4
        events.map @(e) @{ e.name }.should.eql [
            'requested'
            'responded'
            'requested'
            'responded'
        ]
        details = {
            host   = "127.0.0.1"
            port   = "8555"
            method = "GET"
            path   = "/abc"
            headers = {
                host = "127.0.0.1:8555"
                "content-length" = "0"
                connection = "keep-alive"
            }
        }
        events.0.args.should.eql [details]
        events.1.args.0.should.eql (details)
        events.1.args.1.constructor.should.equal IncomingMessage
        events.2.args.0.path.should.equal '/xyz'
