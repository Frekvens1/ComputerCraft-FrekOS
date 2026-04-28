local api = {}

function api.init()
    for _, process in ipairs(frekos.processes) do
        local thread = process.thread

        local ok, reason, filter = coroutine.resume(thread)

        if ok then
            process.filter = filter
        else
            printError("Process crashed during init:", reason)
            process.filter = nil
        end
    end
end

function api.handleEvent()
    local event = { coroutine.yield() }
    local eventName = event[1]

    if frekos.settings.send_events then
        backend.send(event)
    end

    for _, process in ipairs(frekos.processes) do
        local thread = process.thread
        if coroutine.status(thread) ~= "dead" then

            if process.filter == nil or process.filter == eventName then
                local ok, reason, filter = coroutine.resume(thread, table.unpack(event))

                if ok then
                    process.filter = filter
                else
                    printError("Process crashed:", reason)
                    process.filter = nil
                end
            end
        end

    end
end

return api