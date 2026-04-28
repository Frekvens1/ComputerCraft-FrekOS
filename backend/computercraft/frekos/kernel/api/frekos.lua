-- region { private }

local api = {
    processes = {},
}

local shells = {}

-- endregion

function api.spawn(fn, name)
    local process = {
        thread = coroutine.create(fn),
        filter = nil,
        name = name
    }

    table.insert(api.processes, process)
    return process
end

function api.reloadSettings()
    api.settings = fs.loadConfig("/frekos/config/settings.conf")
end

function api.reloadDevice()
    api.device = fs.loadConfig("/frekos/config/device.conf")
end

function api.init()
    api.reloadSettings()
    api.reloadDevice()
end

function api.setShell(shell)
    table.insert(shells, shell)
end

function api.getPrimaryShell()
    return shells[1]
end

function api.getCurrentShell()
    return shells[#shells]
end

return api