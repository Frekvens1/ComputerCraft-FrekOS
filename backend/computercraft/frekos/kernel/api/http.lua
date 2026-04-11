-- region { private }

local api = {
    native = _G.http
}

-- endregion

-- region { native functions }

function api.get(url)
    local ok, err = api.native.request(url)
    if not ok then
        return nil, err
    end

    while true do
        local event, event_url, handle = coroutine.yield()

        if event == "http_success" and event_url == url then
            local content = handle.readAll()
            handle.close()
            return content, nil
        end

        if event == "http_failure" and event_url == url then
            return nil, handle
        end
    end
end

function api.post(...)

end

function api.request(...)
    return api.native.request(...)
end

function api.checkURLAsync(url)

end

function api.checkURL(url)
    return api.native.checkURL(url)
end

function api.websocketAsync(...)

end

function api.websocket(...)
    return api.native.websocket(...)
end

-- endregion

return api
