-- region { private }

local api = {
    native = _G.peripheral,
    names = {},
}

-- endregion

-- region { native functions }

function api.getNames()
    api.names = {}
    for _, side in ipairs(redstone.getSides()) do
        if api.isPresent(side) then
            table.insert(api.names, side)
        end
    end
    return api.names
end

function api.isPresent(name)
    return api.native.isPresent(name)
end

function api.getType(peripheral)
    return api.native.getType(peripheral)
end

function api.hasType(peripheral, peripheral_type)
    return api.native.hasType(peripheral, peripheral_type)
end

function api.getMethods(name)
    return api.native.getMethods(name)
end

function api.getName(peripheral)

end

function api.call(name, method, ...)
    return api.native.call(name, method, ...)
end

function api.wrap(name)
    if not api.isPresent(name) then return nil end

    local methods = api.getMethods(name)
    local obj = {}

    for _, method in ipairs(methods) do
        obj[method] = function(...)
            return api.call(name, method, ...)
        end
    end

    return obj
end

function api.find(ty, filter)
    return api.wrap("right")
end

-- endregion

return api
