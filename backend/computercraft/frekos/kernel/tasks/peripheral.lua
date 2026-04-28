local function task()
    local handleEvent = peripheral.handleEvent
    peripheral.handleEvent = nil

    while true do
        local event = { coroutine.yield() }
        handleEvent(event)
    end
end

return task
