local function task()
    backend.refreshConnection()

    while true do
        local event, url, handle = coroutine.yield()

        if url ~= backend.getWebsocketURL() then
        elseif event == "websocket_message" then
            os.queueEvent(table.unpack(textutils.unserializeJSON(handle)))

        elseif event == "websocket_success" then
            backend.connection = handle

        elseif event == "websocket_failure" then
            backend.refreshConnection()

        elseif event == "websocket_closed" then
            backend.refreshConnection()
        end
    end
end

return task
