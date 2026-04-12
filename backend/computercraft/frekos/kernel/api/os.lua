-- region { private }

local api = {
    native = _G.os
}

-- endregion

-- region { native functions }

function api.shutdown()
    api.native.shutdown()
end

function api.reboot()
    api.native.reboot()
end

function api.setComputerLabel(label)
    api.native.setComputerLabel(label)
end

function api.version()
    return "FrekOS v0.1"
end

function api.queueEvent(name, ...)
    api.native.queueEvent(name, ...)
end

function api.pullEvent(filter)
    return api.pullEventRaw("pull", filter)
end

function api.pullEventRaw(filter)
    return coroutine.yield(filter)
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

function api.sleep(time)
    coroutine.yield()
end

-- endregion

return api
