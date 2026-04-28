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
            os.run("/frekos/apps/welcome_screen.lua")

        elseif event == "websocket_failure" then
            if backend.connection ~= nil then
                os.queueEvent("frekos_backend_disconnected")
                backend.connection = nil
            end

            os.run("/frekos/apps/welcome_screen.lua")
            backend.refreshConnection()

        elseif event == "websocket_closed" then
            if backend.connection ~= nil then
                os.queueEvent("frekos_backend_disconnected")
                backend.connection = nil
            end

            os.run("/frekos/apps/welcome_screen.lua")
            backend.refreshConnection()
        end
    end
end

return task
