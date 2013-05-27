create spy (callbacks) =
    spy middleware (inner) = {
        request (options, callback) =
            callbacks.requested (options)
            inner.request (options) @(response)
                callbacks.responded (options, response)
                callback (response)
    }

exports.create spy = create spy
