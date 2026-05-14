local api = {}

function api.init()
    for _, process in ipairs(frekos.processes) do
        local thread = process.thread

        local result = { coroutine.resume(thread) }

        if result[1] then
            process.filter = { table.unpack(result, 2, #result) }
        else
            backend.send({
                message = "Process crashed during init",
                error = result,
                name = process.name,
            })
            printError("Process crashed during init:", result[2])
            process.filter = nil
        end
    end
end

function api.handleEvent()
    local event = { coroutine.yield() }
    local event_name = event[1]

    if frekos.device.debug_send_events then
        backend.send(event)
    end

    for _, process in ipairs(frekos.processes) do
        local thread = process.thread
        if coroutine.status(thread) ~= "dead" then
            if process.filter == nil or #process.filter == 0 or table.includes(process.filter, event_name) then
                local result = { coroutine.resume(thread, table.unpack(event)) }

                if result[1] then
                    process.filter = { table.unpack(result, 2, #result) }
                else
                    backend.send({
                        message = "Process crashed",
                        error = result,
                        name = process.name
                    })

                    printError("Process crashed:", result[2])
                    process.filter = nil
                end
            end
        else
            -- TODO: Remove dead process
        end

    end
end

return api