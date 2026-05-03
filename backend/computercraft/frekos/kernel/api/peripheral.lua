-- region { private }

local api = {
    native = _G.peripheral,
    names = {},
}

local peripherals = {}
local type_lookup = {}
local peripherals_by_type = {}

local function wrap(name)
    if not api.native.isPresent(name) then
        return nil
    end

    local methods = api.native.getMethods(name)
    local obj = {}

    for _, method in ipairs(methods) do
        obj[method] = function(...)
            return api.native.call(name, method, ...)
        end
    end

    return obj, { api.native.getType(name) }
end

local function wrapModem(name)
    local modem = wrap(name)
    local modem_peripherals = {}

    for _, peripheral in ipairs(modem.getNamesRemote()) do
        local methods = modem.getMethodsRemote(peripheral)
        local obj = {}

        for _, method in ipairs(methods) do
            obj[method] = function(...)
                return modem.callRemote(peripheral, method, ...)
            end
        end

        modem_peripherals[peripheral] = {
            obj, { modem.getTypeRemote(peripheral) }
        }
    end

    return modem_peripherals
end

local function findPeripheral(name)
    local modems = {}
    for _, side in ipairs(redstone.getSides()) do
        if api.isPresent(side) then
            local obj, obj_types = wrap(side)
            if name == side then
                return obj, obj_types
            end

            for _, obj_type in ipairs(obj_types) do
                if obj_type == "peripheral_hub" then
                    table.insert(modems, side)
                end
            end
        end
    end

    for _, modem in ipairs(modems) do
        for obj_name, stats in pairs(wrapModem(modem)) do
            local hub_obj = stats[1]
            local hub_obj_types = stats[2]

            if obj_name == name then
                return hub_obj, hub_obj_types
            end
        end
    end

    return nil, "Peripheral not found"
end

-- endregion

-- region { events }

local function onAttach(name, obj_types, obj)
    peripherals[name] = obj
    for _, obj_type in ipairs(obj_types) do
        if peripherals_by_type[obj_type] == nil then
            peripherals_by_type[obj_type] = {}
        end

        if type_lookup[name] == nil then
            type_lookup[name] = {}
        end

        table.insert(type_lookup[name], obj_type)
        peripherals_by_type[obj_type][name] = obj
    end
end

local function onDetach(name)
    local obj_types = type_lookup[name]
    if obj_types ~= nil then
        for _, obj_type in ipairs(obj_types) do
            peripherals_by_type[obj_type][name] = nil
        end
    end

    peripherals[name] = nil
    type_lookup[name] = nil
end

-- endregion

-- region { native functions }

function api.getNames()
    api.names = {}
    for _, side in ipairs(redstone.getSides()) do
        if api.isPresent(side) then
            table.insert(api.names, side)
        end
    end
    return api.names
end

function api.isPresent(name)
    return api.native.isPresent(name)
end

function api.getType(peripheral)
    if type_lookup[peripheral] then
        return table.unpack(type_lookup[peripheral])
    end

    return api.native.getType(peripheral)
end

function api.hasType(peripheral, peripheral_type)
    return api.native.hasType(peripheral, peripheral_type)
end

function api.getMethods(name)
    return api.native.getMethods(name)
end

function api.getName(peripheral)
    for name, obj in pairs(peripherals) do
        if obj == peripheral then
            return name
        end
    end

    return nil
end

function api.call(name, method, ...)
    return api.native.call(name, method, ...)
end

function api.wrap(name)
    if peripherals[name] then
        return peripherals[name]
    end

    if not api.isPresent(name) then
        return nil
    end

    local methods = api.getMethods(name)
    local obj = {}

    for _, method in ipairs(methods) do
        obj[method] = function(...)
            return api.call(name, method, ...)
        end
    end

    return obj
end

function api.find(ty, filter)
    local result = {}

    local objs = api.getByType(ty)
    if objs then
        for name, obj in pairs(objs) do
            if filter then
                if filter(name, obj) then
                    table.insert(result, obj)
                end
            else
                table.insert(result, obj)
            end
        end
    end

    return table.unpack(result)
end

-- endregion

function api.isInventory(name)
    local types = { api.getType(name) }
    for _, type in ipairs(types) do
        if type == "inventory" then
            return true
        elseif type == "manipulator" then
            local manipulator = api.wrap(name)
            if manipulator.getInventory ~= nil then
                return true
            end
        end
    end
    return false
end

function api.getInventory(name)
    local p = api.get(name)
    if p == nil then
        return nil
    end

    if p.getInventory then
        return p.getInventory()
    end

    return p
end

function api.handleEvent(event)
    if event[1] == "peripheral" then
        local name = event[2]
        local obj, obj_types = findPeripheral(name)
        onAttach(name, obj_types, obj)

        backend.send({
            name = name,
            obj_types = obj_types,
            obj = obj
        })
        storage.updateInventory(name)

    elseif event[1] == "peripheral_detach" then
        onDetach(event[2])
    end
end

function api.init()
    for _, side in ipairs(redstone.getSides()) do
        local obj, obj_types = wrap(side)
        local is_hub = false

        if obj ~= nil then
            onAttach(side, obj_types, obj)
            for _, obj_type in ipairs(obj_types) do
                if obj_type == "peripheral_hub" then
                    is_hub = true
                end
            end
        end

        if is_hub then
            for name, stats in pairs(wrapModem(side)) do
                local hub_obj = stats[1]
                local hub_obj_types = stats[2]

                onAttach(name, hub_obj_types, hub_obj)
            end
        end

    end
end

function api.isOnline(name)
    return peripherals[name] ~= nil
end

function api.getAll()
    return peripherals
end

function api.get(name)
    return peripherals[name]
end

function api.getAllTypes()
    return peripherals_by_type
end

function api.getByType(peripheral_type)
    return peripherals_by_type[peripheral_type]
end

function api.getPeripheralTypes(name)
    return type_lookup[name]
end

return api
