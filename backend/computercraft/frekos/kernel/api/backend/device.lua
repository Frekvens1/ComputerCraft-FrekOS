-- region { private }

local api = {}

-- endregion

-- region { devices }

function api.getAll()
    return backend.get("/devices")
end

function api.getByModule(device_module)
    return backend.get("/devices/module/" .. device_module)
end

function api.getAllOnline()
    return backend.get("/devices/online")
end

function api.get(device_uuid)
    return backend.get("/device/" .. device_uuid)
end

function api.getOnline(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/online")
end

-- endregion

-- region { device states }

function api.getByType(device_type)
    return backend.get("/devices/type/" .. device_type)
end

function api.getState(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/state")
end

function api.updateState(device_uuid, state)
    return backend.post("/device/" .. device_uuid .. "/state", state)
end

function api.patchState(device_uuid, state)
    return backend.patch("/device/" .. device_uuid .. "/state", state)
end

function api.deleteState(device_uuid)
    return backend.delete("/device/" .. device_uuid .. "/state")
end

-- endregion

api.events = {}

function api.events.raw(device_uuid, event)
    return backend.post("/device/" .. device_uuid .. "/event", event)
end

function api.events.teleport(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/events/teleport")
end

return api
