-- region { private }

local api = {}

-- endregion

function api.getAll()
    return backendUtils.get("/devices")
end

function api.getAllOnline()
    return backendUtils.get("/devices/online")
end

function api.getByType(device_type)
    return backendUtils.get("/devices/type/" .. device_type)
end

function api.get(device_uuid)
    return backendUtils.get("/device/" .. device_uuid)
end

function api.getOnline(device_uuid)
    return backendUtils.get("/device/" .. device_uuid .. "/online")
end

api.events = {}

function api.events.teleport(device_uuid)
    return backendUtils.get("/device/" .. device_uuid .. "/events/teleport")
end

return api
