Event Emitter = require 'events'.Event Emitter

handle request (inner, passwords, options, callback) =
    req = @new (Event Emitter)
    inner req = { end() = true }
    req.end() = inner req.end()
    header = options.headers.'proxy-authorization' || ''
    authenticate (header, passwords) @(err, valid, username)        
        if (valid)
            delete(options.headers.'proxy-authorization')
            options.username = username
            inner req := inner.request (options, callback)
        else
            unauthenticated (callback)

    req

authenticate (header, passwords, callback) =
    token = header.split(r/\s+/).pop()
    if (token)
        auth = @new Buffer(token, 'base64').to string()
        parts = auth.split(r/:/)
        username = parts.0
        password = parts.1
        valid = passwords.(username) == password
        callback (nil, valid, username)
    else
        callback(nil, false)

prompt = "Please enter your account details to continue"

unauthenticated (callback) =
    response = @new (Event Emitter)
    response.status code = 407
    response.pipe (r) =
        r.write head (407, 'Proxy-Authenticate': 'Basic realm="' + prompt + '"')
        r.end (prompt)

    callback (response)
    response.emit 'end'            

create middleware for users (passwords) =
    middleware (inner) = {
        request (options, callback) =
            handle request (inner, passwords, options, callback)
    }

exports.for users = create middleware for users
