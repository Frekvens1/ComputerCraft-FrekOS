-- region { private }

local api = {}

-- endregion

function api.refreshSettings()
    api.settings = fileUtils.loadConfig("/frekos/settings.conf")
    api.device = fileUtils.loadConfig("/frekos/device.conf")
end

function api.run(file_path, ...)
    term.setCursorBlink(false)

    local env = {}
    env._ENV = env
    setmetatable(env, { __index = _ENV })
    env.shell = shell

    local okLoad, fn = pcall(loadfile, file_path)
    if not okLoad then
        term.setCursorBlink(true)
        return
    end

    setfenv(fn, env)

    local okRun = pcall(fn, ...)
    if not okRun then
        term.setCursorBlink(true)
        return
    end

    term.setCursorBlink(true)
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

-- region { APIs }

api.api = {}

local function loadAPI(name, file_path)
    if not fs.exists(file_path) then
        return
    end

    local env = {}
    env._ENV = env
    setmetatable(env, { __index = _ENV })
    env.shell = shell

    local okLoad, fn = pcall(loadfile, file_path)
    if not okLoad then
        return
    end

    setfenv(fn, env)

    local okRun, fn_api = pcall(fn)
    if not okRun then
        return
    end

    api.api[name] = fn_api
end

local function loadAPIs()
    loadAPI("device", "/frekos/libs/api/device.lua")
    loadAPI("storage", "/frekos/libs/api/storage.lua")
end

-- endregion

local function beforeLoad()
    print("Loading settings...")
    api.refreshSettings()
    loadAPIs()
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
