local api = {}

function getHostname(path)
    if not path:match("^/") then
        path = "/" .. path
    end

    return FrekOS.settings.hostname .. FrekOS.settings.api_path  .. path
end

function getProtocolHTTP()
    local protocol = "http"
    if FrekOS.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

function getProtocolWS()
    local protocol = "ws"
    if FrekOS.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

function api.get(path)
    local url = getProtocolHTTP() .. getHostname(path)
    local ok, _ = http.checkURL(url)
    if not ok then
        return nil
    end

    local response = http.get(url, nil, true)
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    return text
end

function api.websocket(path)
    local url = getProtocolWS() .. getHostname(path)
    local ws, err = http.websocket(url)

    if not ws then
        return nil, err
    end

    return ws
end

function api.refreshConnection()
    api.connection = api.websocket("/device/" .. FrekOS.settings.device_uuid)
end


function beforeLoad()

end

function afterLoad()
    print("Establishing websocket connection...")
    api.refreshConnection()
    if not api.connection then
        print("Failed to connect.")
    else
        print("Connected!")
    end
end

return api, beforeLoad, afterLoad
