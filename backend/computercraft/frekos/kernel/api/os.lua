-- region { private }

local api = {
    native = _G.os
}

-- endregion

-- region { native functions }

function api.pullEvent(filter)
    return api.pullEventRaw("pull", filter)
end

function api.pullEventRaw(filter)
    return coroutine.yield(filter)
end

function api.sleep(time)
    local id = api.native.startTimer(time)

    while true do
        local event, timerId = coroutine.yield("pull", "timer")
        if timerId == id then
            return
        end
    end
end

function api.version()
    return "FrekOS v0.1"
end

function api.run(path, selected_env)
    local env = {}
    env._ENV = env
    setmetatable(env, { __index = selected_env or _ENV })

    local fn, load_error = loadfile(path)
    if not fn then
        printError("Failed to load program:")
        printError(load_error)
        return nil, load_error
    end

    setfenv(fn, env)

    term.setCursorBlink(false)
    local ok, run_error = pcall(fn)
    term.setCursorBlink(true)

    if not ok then
        printError("Failed to run program:")
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

return api
