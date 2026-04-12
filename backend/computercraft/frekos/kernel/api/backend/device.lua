-- region { private }

local api = {}

-- endregion

function api.getAll()
    return backend.get("/devices")
end

function api.getAllOnline()
    return backend.get("/devices/online")
end

function api.getByType(device_type)
    return backend.get("/devices/type/" .. device_type)
end

function api.get(device_uuid)
    return backend.get("/device/" .. device_uuid)
end

function api.getOnline(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/online")
end

api.events = {}

function api.events.raw(device_uuid, event)
    return backend.post("/device/" .. device_uuid .. "/event", event)
end

function api.events.teleport(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/events/teleport")
end

return api
