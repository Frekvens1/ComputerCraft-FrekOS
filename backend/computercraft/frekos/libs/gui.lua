-- region { private }

local api = {}

-- endregion

local function beforeLoad()
    for name, fn in pairs(fileUtils.loadFolder("/frekos/libs/gui")) do
        api[name] = fn
    end

    api.components = fileUtils.loadFolder("/frekos/libs/gui/components")
end

local function afterLoad()

end

return api, beforeLoad, afterLoad
