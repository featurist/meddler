proxy = require '../src/proxy'
stream = require 'stream'
Transform = stream.Transform

port = process.env.PORT || 3000

js = '
    <script type="text/javascript"
        src="http://www.cornify.com/js/cornify.js">
    </script>
    
    <script type="text/javascript">
        setInterval(function() { cornify_add(); }, 10000)
    </script>
'

cornify (inner) = {
    request (options, callback) =
        inner.request (options) @(response)
            content type = response.headers.'content-type'
            if (content type && content type.index of 'html' > -1)
                rewrite html (response, callback)
            else
                callback (response)
}

rewrite html (response, callback) =
    headers = response.headers
    injected = @new (Transform)
    injected._transform (chunk, encoding, callback) =
        c = chunk.to string().replace(r/<\/body/gi, js + '</body')
        this.push (c)
        callback ()

    delete(headers.'content-length')
    injected.status code = response.status code
    injected.headers = headers
    response.pipe(injected)
    callback (injected)

proxy.create server ( middleware: [ cornify ] ).listen(port)
console.log "http://127.0.0.1:#(port)"
