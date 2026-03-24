-- region { private }

local api = {}
local tasks = {}
local threads = {}

local function startTask(fn)
    local co = coroutine.create(fn)
    threads[#threads + 1] = co
end

-- endregion

function api.addTask(fn)
    tasks[#tasks + 1] = fn
end

function api.supervisor()
    -- Start all existing tasks
    for _, fn in ipairs(tasks) do
        startTask(fn)
    end

    while true do
        -- Resume all running tasks
        for i, co in ipairs(threads) do
            if coroutine.status(co) ~= "dead" then
                local ok, err = coroutine.resume(co)
                if not ok then
                    print("Task crashed:", err)
                end
            end
        end

        -- Start any new tasks added since last loop
        for i, fn in ipairs(tasks) do
            if not threads[i] then
                startTask(fn)
            end
        end

        local f = fs.open("/supervisor.log", "a")
        f.writeLine("Tasks running: " .. #threads)
        f.close()


        -- Yield to allow other threads to run
        sleep(0)
    end
end

return api