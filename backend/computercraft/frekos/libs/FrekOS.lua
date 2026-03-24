-- region { private }

local api = {}

local function backendListener()
    while true do
        local response = backendUtils.getConnection().receive()
        os.queueEvent(table.unpack(textutils.unserialiseJSON(response)))
    end
end

-- endregion

function api.test()
    local response = backendUtils.getConnection().receive()
    os.queueEvent(table.unpack(textutils.unserialiseJSON(response)))
end

function api.refreshSettings()
    api.settings = fileUtils.loadConfig("/frekos/settings.table")
end

-- region { Events }

api.events = {}

function api.events.inject()
    local pullEventRaw = os.pullEventRaw
    os.pullEventRaw = function(...)
        local results = { pullEventRaw(...) }
        api.server.send(fileUtils.sanitize(results))
        return table.unpack(results)
    end
end

function api.events.add()

end

-- endregion

-- region { Server }

api.server = {}

function api.server.send(...)
    local args = { ... }
    backendUtils.getConnection().send(textutils.serialize(args))
end

function api.server.event()

end

-- endregion

local function beforeLoad()
    print("Loading settings...")
    api.refreshSettings()
end

local function afterLoad()
    backgroundTasks.addTask(backendListener)
end

return api, beforeLoad, afterLoad
