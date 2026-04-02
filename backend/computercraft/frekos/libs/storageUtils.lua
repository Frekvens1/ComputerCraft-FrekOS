-- region { private }

local api = {}

-- endregion

function api.getInventory(name)
    if not peripheralsLib.isInventory(name) then
        return nil, "Peripheral is not an inventory"
    end

    local p = peripheralsLib.peripherals[name]
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
            if #item_lookup[item.name][hash].itemGroups == 0 then
                item_lookup[item.name][hash].itemGroups = nil
            end
        else
            item_lookup[item.name][hash].count = item_lookup[item.name][hash].count + item.count
        end
    end

    return {
        device_uuid = FrekOS.device.device_uuid,
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

    FrekOS.api.storage.update(name, inventory)
end

function api.moveItems(storage_1, slot_1, storage_2, slot_2, amount)
    if peripheralsLib.peripherals[storage_1] == nil then
        return nil
    end

    if peripheralsLib.peripherals[storage_2] == nil then
        return nil
    end

    slot_1 = tonumber(slot_1)
    slot_2 = tonumber(slot_2)
    amount = tonumber(amount)

    peripheralsLib.peripherals[storage_1].pushItems(storage_2, slot_1, amount, slot_2)
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
                    if #item_lookup[item.name][hash].itemGroups == 0 then
                        item_lookup[item.name][hash].itemGroups = nil
                    end
                else
                    item_lookup[item.name][hash].count = item_lookup[item.name][hash].count + item.count
                end
            end
        end

        return {
            device_uuid = FrekOS.device.device_uuid,
            storage_uuid = FrekOS.device.device_uuid,
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

        FrekOS.api.storage.update(FrekOS.device.device_uuid, inventory)
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

local function beforeLoad()

end

local function afterLoad()
    FrekOS.events.addTask("storage", function(event)
        if event[1] ~= "frekos_storage" then
            return
        end

        local task = event[2]
        if api[task] ~= nil then
            api[task](table.unpack(event, 3, #event))
        end
    end)

    if turtle then
        FrekOS.events.addTask("turtle_storage", function(event)
            if event[1] ~= "turtle_inventory" then
                return
            end

            api.updateTurtleInventory()
            os.queueEvent("turtle_inventory_updated")
        end)

        api.updateTurtleInventory()
    end
end

return api, beforeLoad, afterLoad
