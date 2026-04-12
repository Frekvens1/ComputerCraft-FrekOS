-- region { private }

local api = {}

-- endregion

function api.getAll()
    return backend.get("/storages")
end

function api.get(storage_name)
    return backend.get("/storage/" .. storage_name)
end

function api.update(storage_name, storage)
    return backend.post("/storage/" .. storage_name, storage)
end

function api.patch(storage_name, storage)
    return backend.patch("/storage/" .. storage_name, storage)
end

function api.delete(storage_name)
    return backend.delete("/storage/" .. storage_name)
end

api.tasks = {}

function api.tasks.moveItems(device_uuid)
    return backend.get("/device/" .. device_uuid .. "/events/teleport")
end

return api
