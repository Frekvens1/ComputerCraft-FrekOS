local function task()
    while true do
        local event = { coroutine.yield("frekos_turtle") }
        local turtle_task = event[2]

        if turtle[turtle_task] ~= nil then
            turtle[turtle_task](table.unpack(event, 3, #event))
        end

    end
end

if turtle then
    return task
end

return function()
end
