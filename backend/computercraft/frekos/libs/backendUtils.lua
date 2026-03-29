-- region { private }

local api = {}

local function getHostname(path)
    if not path:match("^/") then
        path = "/" .. path
    end

    return FrekOS.settings.hostname .. FrekOS.settings.api_path .. path
end

local function getProtocolHTTP()
    local protocol = "http"
    if FrekOS.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

local function getProtocolWS()
    local protocol = "ws"
    if FrekOS.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

-- endregion

local function getURL(path)
    local url = getProtocolHTTP() .. getHostname(path)
    local ok, _ = http.checkURL(url)
    if not ok then
        return nil
    end

    return url
end

function api.get(path, raw)
    local url = getURL(path)
    if not url then
        return nil
    end

    local response = http.get({
        url = url,
        binary = true
    })
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    if raw then
        return text
    else
        return textutils.unserialiseJSON(text)
    end
end

function api.post(path, data)
    local url = getURL(path)
    if not url then
        return nil
    end

    data = fileUtils.sanitize(data)
    local response = http.post({
        url = url,
        body = textutils.serialiseJSON(data),
        headers = {
        ["Content-Type"] = "application/json"
    }
    })
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    return textutils.unserialiseJSON(text)
end

function api.patch(path, data)
    local url = getURL(path)
    if not url then
        return nil
    end

    data = fileUtils.sanitize(data)
    local response = http.post({
        url = url,
        body = textutils.serialiseJSON(data),
        method = "PATCH",
        headers = {
        ["Content-Type"] = "application/json"
    }
    })
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    return textutils.unserialiseJSON(text)
end

function api.delete(path)
    local url = getURL(path)
    if not url then
        return nil
    end

    local response = http.post({
        url = url,
        method = "DELETE",
        binary = true
    })
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    return textutils.unserialiseJSON(text)
end

function api.websocket(path)
    local url = getProtocolWS() .. getHostname(path)
    local ws, err = http.websocket(url)

    if not ws then
        return nil, err
    end

    return ws
end

function api.send(...)
    local args = fileUtils.sanitize({ ... })
    backendUtils.getConnection().send(textutils.serializeJSON(table.unpack(args)))
end

function api.refreshConnection()
    api.connection = api.websocket("/device/" .. FrekOS.settings.device_uuid)
end

function api.getConnection()
    while not api.connection do
        api.refreshConnection()
    end

    return api.connection
end

local function beforeLoad()

end

local function afterLoad()
    print("Establishing websocket connection...")
    api.refreshConnection()
    if not api.connection then
        print("Failed to connect.")
    else
        print("Connected!")
    end
end

return api, beforeLoad, afterLoad
