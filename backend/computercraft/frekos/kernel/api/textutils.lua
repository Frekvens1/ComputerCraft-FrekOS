-- region { private }

local api = {
    native = _G.textutils
}

-- endregion

-- region { native functions }

function api.serialize(tbl, options)
    return api.native.serialize(tbl, options)
end

function api.serializeJSON(tbl, options)
    return api.native.serializeJSON(tbl, options)
end

function api.unserialize(str)
    return api.native.unserialize(str)
end

function api.unserializeJSON(str)
    return api.native.unserializeJSON(str)
end

-- endregion

return api
