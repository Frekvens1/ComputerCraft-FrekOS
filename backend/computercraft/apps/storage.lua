local inventories = {}
local items = {}

function main()
    updateStorage()
    printStorage()
end

function prettyName(name)
	local pretty_name = name
    local colon_pos = string.find(name, ":")

    if colon_pos then
        pretty_name = string.sub(name, colon_pos + 1)
    end

    pretty_name = pretty_name:gsub("_", " ")
    pretty_name = pretty_name:gsub("(%a)(%w*)",
        function(first, rest)
            return first:upper() .. rest:lower()
        end
    )

    return pretty_name
end

function printStorage()
    for name, chest in pairs(inventories) do
        print("[" .. name .. "] Items: " .. chest.item_count .. " | Slots: " .. chest.slots_used)
    end

    print()

    for item_name, item_info in pairs(items) do
        print("[" .. prettyName(item_name) .. "] Count: " .. item_info.item_count .. " | Storages: " .. item_info.storage_count)
        for storage_name, storage_count in pairs(item_info.storages) do
            print("- [" .. storage_name .. "]: " .. storage_count)
        end
    end
end

function isInventory(name)
    local types = { peripheral.getType(name) }
    for _, type in ipairs(types) do
        if type == "inventory" then
            return true
        end
    end
    return false
end

function updateStorage()
    inventories = {}
    items = {}

    for _, name in ipairs(peripheral.getNames()) do
        local p = peripheral.wrap(name)
        if isInventory(name) then
            local slot_items = p.list()
            local inventory_size = p.size()

            local item_count = 0
            local slots_used = 0

            for slot, item in pairs(slot_items) do
                slots_used = slots_used + 1
                item_count = item_count + item.count

                if items[item.name] == nil then
                    items[item.name] = {
                        item_count = item.count,
                        storage_count = 1,
                        storages = { [name] = item.count },
                    }
                else
                    items[item.name].item_count = items[item.name].item_count + item.count
                    if items[item.name].storages[name] == nil then
                        items[item.name].storage_count = items[item.name].storage_count + 1
                        items[item.name].storages[name] = item.count
                    else
                        items[item.name].storages[name] = items[item.name].storages[name] + item.count
                    end
                end
            end

            inventories[name] = {
                peripheral = p,
                size = inventory_size,
                inventory = slot_items,
                item_count = item_count,
                slots_used = slots_used,
                free_slots = inventory_size - slots_used,
            }
        end
    end
end


main()
