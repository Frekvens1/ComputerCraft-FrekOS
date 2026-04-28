local function refreshScreen()
    local shell = frekos.getPrimaryShell()
    if shell and shell.is_running_app then
        return
    end

    os.run("/frekos/apps/welcome_screen.lua")
end

local function task()
    backend.refreshConnection()

    while true do
        local event, url, handle = coroutine.yield()

        if url ~= backend.getWebsocketURL() then
        elseif event == "websocket_message" then
            os.queueEvent(table.unpack(textutils.unserializeJSON(handle)))

        elseif event == "websocket_success" then
            os.queueEvent("frekos_backend_connected")
            backend.connection = handle
            refreshScreen()

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
