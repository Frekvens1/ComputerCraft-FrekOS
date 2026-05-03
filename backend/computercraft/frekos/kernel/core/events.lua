local api = {}

function api.init()
    for _, process in ipairs(frekos.processes) do
        local thread = process.thread

        local ok, result = coroutine.resume(thread)

        if ok then
            process.filter = result
        else
            backend.send({
                message = "Process crashed during init",
                error = result
            })
            printError("Process crashed during init:", result)
            process.filter = nil
        end
    end
end

function api.handleEvent()
    local event = { coroutine.yield() }
    local eventName = event[1]

    if frekos.device.debug_send_events then
        backend.send(event)
    end

    for _, process in ipairs(frekos.processes) do
        local thread = process.thread
        if coroutine.status(thread) ~= "dead" then

            if process.filter == nil or process.filter == eventName then
                local ok, result = coroutine.resume(thread, table.unpack(event))

                if ok then
                    process.filter = result
                else
                    backend.send({
                        message = "Process crashed",
                        error = result
                    })

                    printError("Process crashed:", result)
                    process.filter = nil
                end
            end
        end

    end
end

return api