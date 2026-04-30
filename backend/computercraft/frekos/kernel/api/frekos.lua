-- region { private }

local api = {
    processes = {},
}

local shells = {}

-- endregion

function api.spawn(fn, name)
    local process = {
        thread = coroutine.create(fn),
        filter = nil,
        name = name
    }

    table.insert(api.processes, process)
    return process
end

function api.reloadSettings()
    api.settings = fs.loadConfig("/frekos/config/settings.conf")
end

function api.reloadDevice()
    api.device = fs.loadConfig("/frekos/config/device.conf")
    if fs.exists("/custom_startup.lua") then
        fs.delete("/custom_startup.lua")
    end

    if api.device.custom_startup_script then
        fs.write("/custom_startup.lua", api.device.custom_startup_script)
    end
end

function api.updateState()
    local turtle_values = {}
    if turtle then
        turtle_values = {
            fuel_amount = turtle.fuel(),
            fuel_amount_max = turtle.maxFuel()
        }
    end

    local device_type = "computer"
    if turtle then
        device_type = "turtle"
    elseif pocket then
        device_type = "pocket"
    elseif commands then
        device_type = "command"
    end

    local peripherals = {}
    for name, obj in pairs(peripheral.getAll()) do
        local methods = {}
        for method, method_type in pairs(obj) do
            table.insert(methods, method)
        end

        table.insert(peripherals, {
            name = name,
            types = peripheral.getPeripheralTypes(name),
            methods = methods,
        })
    end

    if table.length(peripherals) == 0 then
        peripherals = nil
    end

    backend.api.device.updateState(api.device.device_uuid, {
        type = device_type,
        has_color = term.isColor(),
        connected_peripherals = peripherals,

        current_volume = 100,
        fuel_amount = orDefault(turtle_values.fuel_amount, -1),
        fuel_amount_max = orDefault(turtle_values.fuel_amount_max, -1),
        gps_position = {
            x = 0,
            y = 0,
            z = 0,
        },
    })
end

function api.init()
    api.reloadSettings()
    api.reloadDevice()
end

function api.setShell(shell)
    table.insert(shells, shell)
end

function api.getPrimaryShell()
    return shells[1]
end

function api.getCurrentShell()
    return shells[#shells]
end

return api