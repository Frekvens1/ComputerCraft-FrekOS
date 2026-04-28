local function task()
    local function updateStorage()
        if turtle then
            storage.updateTurtleInventory()
        end

        local inventories = peripheral.getByType("inventory")
        if inventories then
            for name, obj in pairs(inventories) do
                storage.updateInventory(name)
            end
        end
    end

    while true do
        local event = { coroutine.yield() }

        if event[1] == "frekos_storage" then
            local storage_task = event[2]
            if storage[storage_task] ~= nil then
                storage[storage_task](table.unpack(event, 3, #event))
            end

        elseif event[1] == "turtle_inventory" then
            storage.updateTurtleInventory()

        elseif event[1] == "frekos_backend_connected" then
            updateStorage()
        end

    end
end

return task
