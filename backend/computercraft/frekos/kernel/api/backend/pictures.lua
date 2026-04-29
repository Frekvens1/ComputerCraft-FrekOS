-- region { private }

local api = {}

-- endregion

-- region { pictures }

function api.getAll()
    return backend.get("/pictures")
end

function api.getBimg(picture_uuid)
    return backend.get("/picture/" .. picture_uuid .. "/bimg", true)
end

function api.get(picture_uuid)
    return backend.get("/picture/" .. picture_uuid)
end

function api.update(picture_uuid, picture)
    return backend.post("/picture/" .. picture_uuid, picture)
end

function api.patch(picture_uuid, picture)
    return backend.patch("/picture/" .. picture_uuid, picture)
end

function api.delete(picture_uuid)
    return backend.delete("/picture/" .. picture_uuid)
end

-- endregion

return api
