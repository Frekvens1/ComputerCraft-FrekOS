-- region { private }

local api = {
    native = _G.os
}

-- endregion

-- region { native functions }

function api.pullEvent(...)
    local args = { ... }
    if table.length(args) > 0 and not table.includes(args, "terminate") then
        table.insert(args, "terminate")
    end

    local event = { api.pullEventRaw(table.unpack(args)) }
    local name = event[1]

    if name == "terminate" then
        error("Terminated", 0)
    end

    return table.unpack(event)
end

function api.pullEventRaw(...)
    return coroutine.yield(...)
end

function api.sleep(time)
    local id = api.native.startTimer(time)

    while true do
        local event, timerId = api.pullEvent("timer")
        if timerId == id then
            return
        end
    end
end

function api.version()
    return "FrekOS v0.1"
end

function api.run(env_or_path, path_or_nil, ...)
    local isCursorBlink = term.getCursorBlink()

    local env = {}
    local selected_env, path, args

    if type(env_or_path) == "table" then
        selected_env = env_or_path
        path = path_or_nil
        args = { ... }
    else
        selected_env = _G
        path = env_or_path
        args = { path_or_nil, ... }
    end

    env._ENV = env
    setmetatable(env, { __index = table.deepCopy(selected_env) })

    local fn, load_error = loadfile(path)
    if not fn then
        printError("Failed to load program:")
        printError(load_error)
        return nil, load_error
    end

    setfenv(fn, env)

    term.setCursorBlink(false)
    local ok, run_error = pcall(fn, table.unpack(args))
    term.setCursorBlink(isCursorBlink)

    if not ok then
        if run_error ~= "Terminated" then
            printError("Program crashed:")
            backend.send({
                message = "Program crashed",
                error = run_error,
                path = path,
                args = args
            })
        end
        printError(run_error)
        return nil, run_error
    end

    return true
end

function api.queueEvent(name, ...)
    return api.native.queueEvent(name, ...)
end

function api.startTimer(time)
    return api.native.startTimer(time)
end

function api.cancelTimer(token)
    return api.native.cancelTimer(token)
end

function api.setAlarm(time)
    return api.native.setAlarm(time)
end

function api.cancelAlarm(token)
    return api.native.cancelAlarm(token)
end

function api.shutdown()
    return api.native.shutdown()
end

function api.reboot()
    return api.native.reboot()
end

function api.getComputerID()
    return api.native.getComputerID()
end

function api.computerID()
    return api.getComputerID()
end

function api.getComputerLabel()
    return api.native.getComputerLabel()
end

function api.computerLabel()
    return api.getComputerLabel()
end

function api.setComputerLabel(label)
    return api.native.setComputerLabel(label)
end

function api.clock()
    return api.native.clock()
end

function api.time(locale)
    return api.native.time(locale)
end

function api.day(locale)
    return api.native.day(locale)
end

function api.epoch(locale)
    return api.native.epoch(locale)
end

function api.date(format, time)
    return api.native.date(format, time)
end

-- endregion

function _G.sleep(time)
    api.sleep(time)
end

function api.safeSleep(time)
    local id = api.native.startTimer(time)

    while true do
        local event, timerId = coroutine.yield("timer")
        if timerId == id then
            return
        end
    end
end

return api
