-- region { private }

local api = {}

-- endregion

function api.refreshSettings()
    api.settings = fileUtils.loadConfig("/frekos/settings.conf")
end

-- region { Events }

api.events = {
    tasks = {}
}

function api.events.inject()
    local lastEvent = nil
    local pullEventRaw = os.pullEventRaw
    os.pullEventRaw = function(...)
        local event = { pullEventRaw(...) }

        if not table.compare(event, lastEvent) then
            if api.settings.send_events then
                api.server.send(fileUtils.sanitize(event))
            end

            api.events.handleTasks(event)
        end

        lastEvent = event
        return table.unpack(event)
    end
end

function api.events.addTask(task_id, fn)
    api.events.tasks[task_id] = fn
end

function api.events.removeTask(task_id)
    api.events.tasks[task_id] = nil
end

function api.events.handleTasks(event)
    for _, task_fn in pairs(api.events.tasks) do
        task_fn(event)
    end
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
    api.events.addTask("backend", function(event)
        if event[1] == "websocket_message" then
            local raw = event[3]
            local websocket_events = textutils.unserialiseJSON(raw)

            if type(websocket_events[1]) == "string" then
                os.queueEvent(table.unpack(websocket_events))
                return
            end

            if type(websocket_events[1]) == "table" then
                for _, websocket_event in ipairs(websocket_events) do
                    os.queueEvent(table.unpack(websocket_event))
                end
                return
            end

            print("Unknown websocket event format:", raw)
        end
    end)
end

return api, beforeLoad, afterLoad
