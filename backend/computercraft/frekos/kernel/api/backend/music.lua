-- region { private }

local api = {}

-- endregion

-- region { playlists }

api.playlists = {}

function api.playlists.getAll()
    return backend.get("/music/playlists")
end

function api.playlists.get(playlist_uuid)
    return backend.get("/music/playlist/" .. playlist_uuid)
end

function api.playlists.update(playlist_uuid, playlist)
    return backend.post("/music/playlist/" .. playlist_uuid, playlist)
end

function api.playlists.patch(playlist_uuid, playlist)
    return backend.patch("/music/playlist/" .. playlist_uuid, playlist)
end

function api.playlists.delete(playlist_uuid)
    return backend.delete("/music/playlist/" .. playlist_uuid)
end

-- endregion

-- region { dfpwm }

api.dfpwm = {}

function api.dfpwm.getAll()
    return backend.get("/music/dfpwm")
end

function api.dfpwm.getStream(dfpwm_uuid)
    return backend.get("/music/dfpwm/" .. dfpwm_uuid .. "/stream", true)
end

function api.dfpwm.getDownload(dfpwm_uuid)
    return backend.get("/music/dfpwm/" .. dfpwm_uuid .. "/download", true)
end

function api.dfpwm.get(dfpwm_uuid)
    return backend.get("/music/dfpwm/" .. dfpwm_uuid)
end

function api.dfpwm.update(dfpwm_uuid, dfpwm)
    return backend.post("/music/dfpwm/" .. dfpwm_uuid, dfpwm)
end

function api.dfpwm.patch(dfpwm_uuid, dfpwm)
    return backend.patch("/music/dfpwm/" .. dfpwm_uuid, dfpwm)
end

function api.dfpwm.delete(dfpwm_uuid)
    return backend.delete("/music/dfpwm/" .. dfpwm_uuid)
end

-- endregion

return api
