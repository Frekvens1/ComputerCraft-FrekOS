-- region { private }

local api = {}

-- endregion

function api.init()
    for name, fn in pairs(fs.loadFolder("/frekos/kernel/api/gui")) do
        api[name] = fn
    end

    api.components = fs.loadFolder("/frekos/kernel/api/gui/components")
end

return api
