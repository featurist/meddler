proxy = require '../proxy'
http = require 'http'
httpism = require 'httpism'

describe 'proxy'
    
    remote server = http.create server @(req, res)
        res.end "I am remote"
    
    proxy server = proxy.create server()

    before
        remote server.listen 8555
        proxy server.listen 8666
    
    after
        remote server.close()
        proxy server.close()
    
    get (url) using the proxy (proxy) =
        httpism.get! (url) { proxy = proxy }
    
    describe 'when the proxy credentials are correct'
    
        it 'forwards requests to URLs'
            response = get! "http://127.0.0.1:8555" using the proxy "http://featurist:cats@127.0.0.1:8666"
            response.status code.should.equal 200
            response.body.should.equal 'I am remote'
    
    describe 'when the proxy credentials are missing'

        it 'responds with a 407'
            response = get! "http://127.0.0.1:8555" using the proxy "http://127.0.0.1:8666"
            response.status code.should.equal 407
            response.body.should.equal 'Please enter your account details to continue'

    describe 'when the proxy credentials are wrong'

        it 'responds with a 407'
            response = get! "http://127.0.0.1:8555" using the proxy "http://featurist:zombie@127.0.0.1:8666"
            response.status code.should.equal 407
            response.body.should.equal 'Please enter your account details to continue'
