-- region { private }

local api = {}

local function getHostname(path)
    if not path:match("^/") then
        path = "/" .. path
    end

    return frekos.settings.hostname .. frekos.settings.api_path .. path
end

local function getProtocolHTTP()
    local protocol = "http"
    if frekos.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

local function getProtocolWS()
    local protocol = "ws"
    if frekos.settings.has_ssl then
        protocol = protocol .. "s"
    end

    return protocol .. "://"
end

local function getURL(path)
    local url = getProtocolHTTP() .. getHostname(path)
    local ok, _ = http.checkURL(url)
    if not ok then
        return nil
    end

    return url
end

-- endregion

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

    data = fs.sanitize(data)
    local response = http.patch({
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

function api.delete(path)
    local url = getURL(path)
    if not url then
        return nil
    end

    local response = http.delete({
        url = url,
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
    if not api.getConnection() then
        return
    end

    local args = fs.sanitize({ ... })
    api.getConnection().send(textutils.serializeJSON(table.unpack(args)))
end

function api.refreshConnection()
    api.websocket(api.getWebsocketURL(true))
end

function api.getWebsocketURL(only_path)
    local path = "/device/" .. frekos.settings.device_uuid
    if only_path then
        return path
    else
        return getProtocolWS() .. getHostname(path)
    end
end

function api.getConnection()
    return api.connection
end

function api.init()
    api.api = fs.loadFolder("/frekos/kernel/api/backend")
end

return api
