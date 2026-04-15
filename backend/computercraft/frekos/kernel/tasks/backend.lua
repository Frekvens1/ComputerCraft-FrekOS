local function task()
    backend.refreshConnection()

    while true do
        local event, url, handle = coroutine.yield()

        if url ~= backend.getWebsocketURL() then
        elseif event == "websocket_message" then
            os.queueEvent(table.unpack(textutils.unserializeJSON(handle)))

        elseif event == "websocket_success" then
            backend.connection = handle
            os.run("/frekos/apps/welcome_screen.lua")

        elseif event == "websocket_failure" then
            backend.connection = nil
            os.run("/frekos/apps/welcome_screen.lua")
            backend.refreshConnection()

        elseif event == "websocket_closed" then
            backend.connection = nil
            os.run("/frekos/apps/welcome_screen.lua")
            backend.refreshConnection()
        end
    end
end

return task
