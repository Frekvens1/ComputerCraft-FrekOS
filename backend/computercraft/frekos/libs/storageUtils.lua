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
        device_uuid = FrekOS.settings.device_uuid,
        name = name,
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

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
