-- region { private }

local api = {}

-- endregion

function api.getInventory(name)
    if not peripheral.isInventory(name) then
        return nil, "Peripheral is not an inventory"
    end

    local p = peripheral.getInventory(name)

    local item_list = p.list()
    local slots_total = p.size()

    local item_count = 0
    local slots_used = 0

    local items = {}
    local item_lookup = {}

    for slot, item in pairs(item_list) do
        slots_used = slots_used + 1
        item_count = item_count + item.count
        items[tostring(slot)] = item

        local hash = item.nbt
        if hash == nil then
            hash = item.name
        end

        if not item_lookup[item.name] then
            item_lookup[item.name] = {}
        end

        if not item_lookup[item.name][hash] then
            item_lookup[item.name][hash] = p.getItemDetail(slot)
            if item_lookup[item.name][hash] ~= nil then
                if #item_lookup[item.name][hash].itemGroups == 0 then
                    item_lookup[item.name][hash].itemGroups = nil
                end
            end
        else
            item_lookup[item.name][hash].count = item_lookup[item.name][hash].count + item.count
        end
    end

    return {
        device_uuid = frekos.device.device_uuid,
        storage_uuid = name,
        slots_used = slots_used,
        slots_total = slots_total,
        items_total = item_count,
        items = items,
        lookup = item_lookup
    }
end

function api.updateInventory(name)
    local inventory, err = api.getInventory(name)
    if not inventory then
        return nil, err
    end

    backend.api.storage.update(name, inventory)
end

function api.moveItems(storage_1, slot_1, storage_2, slot_2, amount)
    if not peripheral.isOnline(storage_1) then
        return nil
    end

    if not peripheral.isOnline(storage_2) then
        return nil
    end

    slot_1 = tonumber(slot_1)
    slot_2 = tonumber(slot_2)
    amount = tonumber(amount)

    local storage_1_is_manipulator = peripheral.getType(storage_1) == "manipulator"
    local storage_2_is_manipulator = peripheral.getType(storage_2) == "manipulator"

    if storage_1_is_manipulator and storage_2_is_manipulator then
        if storage_1 == storage_2 then
            backend.send("Unable to transfer between manipulators")
            return nil, "Unable to transfer between manipulators"
        end
    end

    if storage_2_is_manipulator then
        peripheral.getInventory(storage_2).pullItems(storage_1, slot_1, amount, slot_2)
    else
        peripheral.getInventory(storage_1).pushItems(storage_2, slot_1, amount, slot_2)
    end

    api.updateInventory(storage_1)
    if storage_1 ~= storage_2 then
        api.updateInventory(storage_2)
    end
end

if turtle then
    function api.getTurtleInventory(selected_slot)
        if selected_slot == nil then
            selected_slot = turtle.getSelectedSlot()
        end

        local slots_total = 16

        local item_count = 0
        local slots_used = 0

        local items = {}
        local item_lookup = {}

        for slot = 1, slots_total do
            local item = turtle.getItemDetail(slot)

            if item then
                slots_used = slots_used + 1
                item_count = item_count + item.count
                items[tostring(slot)] = item

                local hash = item.nbt
                if hash == nil then
                    hash = item.name
                end

                if not item_lookup[item.name] then
                    item_lookup[item.name] = {}
                end

                if not item_lookup[item.name][hash] then
                    item_lookup[item.name][hash] = turtle.getItemDetail(slot, true)
                    if item_lookup[item.name][hash] ~= nil then
                        if #item_lookup[item.name][hash].itemGroups == 0 then
                            item_lookup[item.name][hash].itemGroups = nil
                        end
                    end
                else
                    item_lookup[item.name][hash].count = item_lookup[item.name][hash].count + item.count
                end
            end
        end

        return {
            device_uuid = frekos.device.device_uuid,
            storage_uuid = frekos.device.device_uuid,
            slots_used = slots_used,
            slots_total = slots_total,
            items_total = item_count,
            items = items,
            lookup = item_lookup,
            is_turtle = true,
            selected_slot = selected_slot
        }
    end

    function api.updateTurtleInventory(selected_slot)
        local inventory, err = api.getTurtleInventory(selected_slot)
        if not inventory then
            return nil, err
        end

        backend.api.storage.update(frekos.device.device_uuid, inventory)
    end

    function api.moveTurtleItems(slot_1, slot_2, amount)
        local selected_slot = turtle.getSelectedSlot()
        if slot_1 == slot_2 then
            return nil
        end

        local currentSlot = turtle.getSelectedSlot()

        slot_1 = tonumber(slot_1)
        slot_2 = tonumber(slot_2)
        amount = tonumber(amount)

        if (currentSlot ~= slot_1) then
            turtle.select(slot_1)
        end

        turtle.transferTo(slot_2, amount)

        api.updateTurtleInventory(selected_slot)
        if (currentSlot ~= slot_1) then
            turtle.select(currentSlot)
        end
    end
end

return api
