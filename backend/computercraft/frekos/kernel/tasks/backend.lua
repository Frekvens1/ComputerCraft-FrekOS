local function refreshScreen()
    local shell = frekos.getPrimaryShell()
    if shell and shell.is_running_app then
        return
    end

    os.run("/frekos/apps/welcome_screen.lua")
end

local function onConnection()
    frekos.updateState()
    for _, message in ipairs(backend.message_queue) do
        backend.send(table.unpack(message))
    end

    backend.message_queue = {}
end

local function onRemoteCommand(command, args)
    if command == "wipe_device" then
        os.run("/frekos/apps/wipe_device.lua")

    elseif command == "update" then
        os.run("/frekos/apps/update.lua")

    elseif command == "clean_install" then
        os.run("/frekos/apps/clean_install.lua")

    elseif command == "reboot" then
        os.reboot()
    end
end

local function task()
    backend.refreshConnection()

    while true do
        local event, url, handle = coroutine.yield()

        if url ~= backend.getWebsocketURL() then
        elseif event == "websocket_message" then
            local backend_event = textutils.unserializeJSON(handle)
            if backend_event[1] == "frekos_remote_command" then
                onRemoteCommand(backend_event[2], table.unpack(backend_event, 3, #backend_event))
            else
                os.queueEvent(table.unpack(backend_event))
            end

        elseif event == "websocket_success" then
            os.queueEvent("frekos_backend_connected")
            backend.connection = handle
            refreshScreen()
            onConnection()

            backend.send({ task = "frekos_device_ready" })

        elseif event == "websocket_failure" then
            if backend.connection ~= nil then
                os.queueEvent("frekos_backend_disconnected")
                backend.connection = nil
            else
                os.safeSleep(10)
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
