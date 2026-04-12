-- region { private }

local api = {
    native = _G.textutils
}

-- endregion

-- region { native functions }

function api.serialize(tbl, options)
    return api.native.serialize(tbl, options)
end

function api.serialise(tbl, options)
    return api.serialize(tbl, options)
end

function api.serializeJSON(tbl, options)
    return api.native.serializeJSON(tbl, options)
end

function api.serialiseJSON(tbl, options)
    return api.serializeJSON(tbl, options)
end

function api.unserialize(str)
    return api.native.unserialize(str)
end

function api.unserialise(str)
    return api.unserialize(str)
end

function api.unserializeJSON(str)
    return api.native.unserializeJSON(str)
end

function api.unserialiseJSON(str)
    return api.unserializeJSON(str)
end



-- endregion

return api
