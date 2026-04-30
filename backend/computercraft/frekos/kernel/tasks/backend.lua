local function refreshScreen()
    local shell = frekos.getPrimaryShell()
    if shell and shell.is_running_app then
        return
    end

    os.run("/frekos/apps/welcome_screen.lua")
end

local function onConnection()
    frekos.updateState()
end

local function task()
    backend.refreshConnection()

    while true do
        local event, url, handle = coroutine.yield()

        if url ~= backend.getWebsocketURL() then
        elseif event == "websocket_message" then
            local backend_event = textutils.unserializeJSON(handle)
            if backend_event[1] == "frekos_wipe_device" then
                os.run("/frekos/apps/wipe_device.lua")
            end

            os.queueEvent(table.unpack(backend_event))

        elseif event == "websocket_success" then
            os.queueEvent("frekos_backend_connected")
            backend.connection = handle
            refreshScreen()
            onConnection()

            backend.send({
                task = "frekos_backend_connected",
                message = "Ready",
                status = true
            })

        elseif event == "websocket_failure" then
            if backend.connection ~= nil then
                os.queueEvent("frekos_backend_disconnected")
                backend.connection = nil
            end

            refreshScreen()
            backend.refreshConnection()

        elseif event == "websocket_closed" then
            if backend.connection ~= nil then
                os.queueEvent("frekos_backend_disconnected")
                backend.connection = nil
            end

            refreshScreen()
            backend.refreshConnection()
        end
    end
end

return task
