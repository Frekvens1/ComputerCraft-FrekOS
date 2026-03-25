-- region { private }

local api = {
    types = {},
    active = {},
    detached = {},
    peripherals = {},
}

local function setActivePeripheral(name)
    api.detached[name] = nil
    api.active[name] = true

    if not api.peripherals[name] then
        api.peripherals[name] = peripheral.wrap(name)
    end

    if not api.types[name] then
        api.types[name] = { peripheral.getType(name) }
    end
end

local function setDetachedPeripheral(name)
    api.active[name] = nil
    api.detached[name] = true
end


-- endregion

function api.reload()
    api.types = {}
    api.active = {}
    api.detached = {}
    api.peripherals = {}

    for _, name in ipairs(peripheral.getNames()) do
        setActivePeripheral(name)
    end
end

local function beforeLoad()

end

local function afterLoad()
    print("Fetching connected peripherals...")

    api.reload()
    FrekOS.events.addTask("peripherals", function(event)
        local allowed_events = { 'peripheral', 'peripheral_detach' }
        if not table.includes(allowed_events, event[1]) then
            return
        end

        local event_name = event[1]
        local peripheral_name = event[2]

        if event_name == "peripheral" then
            setActivePeripheral(peripheral_name)
        elseif event_name == "peripheral_detach" then
            setDetachedPeripheral(peripheral_name)
        end
    end)
end

return api, beforeLoad, afterLoad
