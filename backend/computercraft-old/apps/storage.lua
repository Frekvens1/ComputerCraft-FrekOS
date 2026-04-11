local system = {}

local scroll = 0
local lines = {}

function main()
    clear()
    updateStorage()
    printStorage()
    scrollRender()
end

-- region { Inventory management }

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
    system = {
        slots_free = 0,
        slots_used = 0,
        slots_total = 0,
        items_total = 0,
        inventories = {},
        items = {},
    }

    for _, name in ipairs(peripheral.getNames()) do
        local p = peripheral.wrap(name)
        if isInventory(name) then
            local slot_items = p.list()
            local slots_total = p.size()

            local item_count = 0
            local slots_used = 0

            for slot, item in pairs(slot_items) do
                slots_used = slots_used + 1
                item_count = item_count + item.count

                if system.items[item.name] == nil then
                    system.items[item.name] = {
                        item_count = item.count,
                        storage_count = 1,
                        storages = { [name] = item.count },
                    }
                else
                    system.items[item.name].item_count = system.items[item.name].item_count + item.count
                    if system.items[item.name].storages[name] == nil then
                        system.items[item.name].storage_count = system.items[item.name].storage_count + 1
                        system.items[item.name].storages[name] = item.count
                    else
                        system.items[item.name].storages[name] = system.items[item.name].storages[name] + item.count
                    end
                end
            end

            system.slots_free = system.slots_used + slots_total - slots_used
            system.slots_used = system.slots_used + slots_used
            system.slots_total = system.slots_used + slots_total
            system.items_total = system.slots_used + item_count

            system.inventories[name] = {
                peripheral = p,
                inventory = slot_items,
                item_count = item_count,
                slots_free = slots_total - slots_used,
                slots_used = slots_used,
                slots_total = slots_total,
            }
        end
    end
end

-- endregion

-- region { Display render }

function scrollRender()
    renderScreen()

    while true do
        local event, direction, _, _ = os.pullEvent()
        if event == "mouse_scroll" then
            if direction == 1 then
                scrollDown()
            else
                scrollUp()
            end

            renderScreen()
        end
    end
end

function printStorage()
    lines = {}

    addLine("Slots: " .. system.slots_used .. "/" .. system.slots_total .. " | Items total: " .. system.items_total)
    addLine(hr())

    addLine()
    addLine("Inventories")
    addLine(hr())

    for name, chest in pairs(system.inventories) do
        addLine("[" .. name .. "] Items: " .. chest.item_count .. " | Slots: " .. chest.slots_used .. "/" .. chest.slots_total)
    end

    addLine()
    addLine("Items")
    addLine(hr())

    for item_name, item_info in pairs(system.items) do
        addLine("[" .. prettyName(item_name) .. "] Count: " .. item_info.item_count .. " | Storages: " .. item_info.storage_count)
        for storage_name, storage_count in pairs(item_info.storages) do
            addLine("- [" .. storage_name .. "]: " .. storage_count)
        end

        addLine()
    end
end

function clear()
   term.clear()
   term.setCursorPos(1,1)
end

function hr()
    local w = term.getSize()
    return string.rep("-", w)
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

function addLine(text)
    if text == nil then
        text = ""
    end

    table.insert(lines, text)
end

function renderScreen()
    term.clear()
    local w, h = term.getSize()
    for i = 1, h do
        local lineIndex = i + scroll
        if lines[lineIndex] then
            term.setCursorPos(1, i)
            term.write(lines[lineIndex])
        end
    end
end

function scrollUp()
    if scroll > 0 then scroll = scroll - 1 end
end

function scrollDown()
    if scroll < #lines - 1 then scroll = scroll + 1 end
end

-- endregion

main()

-- Fast lookup ( list() ):

-- count: int
-- name: str (ItemID)
-- nbt: str (Hashed. If item is changed)

-- Item fields ( getItemDetail(slot) ):

-- itemGroups = {}
-- maxCount: int
-- maxDamage: int
-- damage: int
-- durability?: float (percentage)
-- unbreakable?: bool
-- displayName: str
-- name: str (ItemID)
-- nbt: str (Hashed. If item is changed)
-- lore: { string }
-- tags: {[key: str]: bool}
-- mapColour?: int
-- mapColor?: int
-- enchantments
-- -- name: str (enchantID)
-- -- displayName: str
-- -- level: int
-- potionEffects
-- -- name: str (enchantID)
-- -- displayName: str
-- -- duration?: int
-- -- potency?: int
