-- region { private }

local api = {
    native = _G.http
}

local function awaitResponse(url)
    while true do
        local event, event_url, handle = coroutine.yield()

        if event == "http_success" and event_url == url then
            local content = handle.readAll()
            handle.close()

            return content
        end

        if event == "http_failure" and event_url == url then
            return nil, handle
        end
    end
end

local function parseParameters(method, ...)
    local args = { ... }
    if type(args[1]) == "table" then
        return args[1]
    else
        if method == "GET" then
            return {
                url = args[1],
                headers = args[2],
                binary = args[3]
            }
        elseif method == "POST" then
            return {
            url = args[1],
            body = args[2],
            headers = args[3],
            binary = args[4]
        }
        end

    end
end

-- endregion

-- region { native functions }

function api.getAsync(...)
    local params = parseParameters("GET", ...)

    api.native.request({
        url = params.url,
        headers = params.headers,
        binary = params.binary
    })
end

function api.get(...)
    local params = parseParameters("GET", ...)
    api.getAsync(params)
    return awaitResponse(params.url)
end

function api.postAsync(...)
    local params = parseParameters("POST", ...)

    api.native.request({
        url = params.url,
        body = params.data,
        headers = params.headers,
        binary = params.binary,
        method = params.method or "POST",
        redirect = params.redirect,
        timeout = params.timeout
    })
end

function api.post(...)
    local params = parseParameters("POST", ...)
    api.postAsync(params)
    return awaitResponse(params.url)
end

function api.patchAsync(...)
    local params = parseParameters("PATCH", ...)

    api.native.request({
        url = params.url,
        body = params.data,
        headers = params.headers,
        binary = params.binary,
        method = "PATCH",
        redirect = params.redirect,
        timeout = params.timeout
    })
end

function api.patch(...)
    local params = parseParameters("PATCH", ...)
    api.patchAsync(params)
    return awaitResponse(params.url)
end

function api.deleteAsync(...)
    local params = parseParameters("DELETE", ...)

    api.native.request({
        url = params.url,
        body = params.data,
        headers = params.headers,
        binary = params.binary,
        method = "DELETE",
        redirect = params.redirect,
        timeout = params.timeout
    })
end

function api.delete(...)
    local params = parseParameters("DELETE", ...)
    api.deleteAsync(params)
    return awaitResponse(params.url)
end

function api.request(...)
    return api.native.request(...)
end

function api.checkURLAsync(url)
    return api.native.checkURL(url)
end

function api.checkURL(url)
    return api.checkURL(url)
end

function api.websocketAsync(...)
    return api.native.websocket(...)
end

function api.websocket(...)
    return api.websocketAsync(...)
end

-- endregion

return api
