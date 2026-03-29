-- region { private }

local api = {}

-- endregion

function api.getAll()
    return backendUtils.get("/storages")
end

function api.get(storage_name)
    return backendUtils.get("/storage/" .. storage_name)
end

function api.update(storage_name, storage)
    return backendUtils.post("/storage/" .. storage_name, storage)
end

function api.patch(storage_name, storage)
    return backendUtils.patch("/storage/" .. storage_name, storage)
end

function api.delete(storage_name)
    return backendUtils.delete("/storage/" .. storage_name)
end

api.events = {}

function api.events.teleport(device_uuid)
    return backendUtils.get("/device/" .. device_uuid .. "/events/teleport")
end

return api
