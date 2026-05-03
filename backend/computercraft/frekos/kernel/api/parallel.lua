-- region { private }

local api = {}

-- endregion

function api.waitForAny(...)
    local funcs = { ... }
    local threads = {}
    local filters = {}

    for i, fn in ipairs(funcs) do
        local co = coroutine.create(fn)
        threads[i] = co
        filters[i] = nil
    end

    while true do
        local event = { os.pullEventRaw() }

        for i, co in ipairs(threads) do
            if coroutine.status(co) ~= "dead" then
                local filter = filters[i]

                if filter == nil or filter == event[1] then
                    local ok, result = coroutine.resume(co, table.unpack(event))

                    if not ok then
                        error(result, 0)
                    end

                    if coroutine.status(co) == "dead" then
                        return result
                    end

                    filters[i] = result
                end
            end
        end
    end
end

function api.waitForAll(...)
    local funcs = { ... }
    local threads = {}
    local filters = {}
    local alive = 0

    for i, fn in ipairs(funcs) do
        local co = coroutine.create(fn)
        threads[i] = co
        filters[i] = nil
        alive = alive + 1
    end

    while alive > 0 do
        local event = { os.pullEventRaw() }

        for i, co in ipairs(threads) do
            if coroutine.status(co) ~= "dead" then
                local filter = filters[i]

                if filter == nil or filter == event[1] then
                    local ok, result = coroutine.resume(co, table.unpack(event))

                    if not ok then
                        error(result, 0)
                    end

                    if coroutine.status(co) == "dead" then
                        alive = alive - 1
                        filters[i] = nil
                    else
                        filters[i] = result
                    end
                end
            end
        end
    end

    return true
end

return api
