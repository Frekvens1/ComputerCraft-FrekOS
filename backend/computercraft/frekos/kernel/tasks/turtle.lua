local function task()
    while true do
        local event = { coroutine.yield("frekos_turtle") }

        if event[1] == "frekos_turtle" then
            local turtle_task = event[2]
            if turtle[turtle_task] ~= nil then
                turtle[turtle_task](table.unpack(event, 3, #event))
            end
        end

    end
end

if turtle then
    return task
end

return function()  end
