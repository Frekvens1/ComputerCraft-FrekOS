local pullEvent = os.pullEvent
local pullEventRaw = os.pullEventRaw

function main()
    kernelLoopTest()
end

function kernelLoopTest()
    print("kernelLoop starting")

    while true do
        print("waiting for event")
        local event = { pullEventRaw() }
        local eventName = event[1]
        print("got event:", eventName)
    end
end

function kernelLoop()
    while true do
        local event = { pullEventRaw() }
        print(textutils.serialize(event))
        local eventName = event[1]

        for _, process in ipairs(frekos.processes) do
            local thread = process.thread
            print(coroutine.status(thread))
            if coroutine.status(thread) ~= "dead" then

                if process.filter == nil or process.filter == eventName then
                    local ok, reason, filter = coroutine.resume(thread, table.unpack(event))

                    if ok then
                        if reason == "pull" then
                            process.filter = filter
                        else
                            process.filter = nil
                        end
                    else
                        printError("Process crashed:", reason)
                        process.filter = nil
                    end
                end
            end
        end
    end
end


function os.pullEvent(filter)
    return coroutine.yield("pull", filter)
end

function os.pullEventRaw(filter)
    return coroutine.yield("pull", filter)
end

local frekos = {
    processes = {}
}

function frekos.spawn(fn)
    local process = {
        thread = coroutine.create(fn),
        filter = nil,
    }
    table.insert(frekos.processes, process)
    return process
end

_G.frekos = frekos

frekos.spawn(function()
    while true do
        print("Process A running")
        coroutine.yield()
    end
end)

main()
