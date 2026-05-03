local allowed_devices = { ... }

local button = gui.components.button

function main()
    local app = gui.createApp(refreshDevices())
    gui.render(app)
end

function doTeleport(device_uuid)
    backend.api.device.events.teleport(device_uuid)
end

function refreshDevices()
    local devices = {}
    if #allowed_devices == 0 then
        devices = backend.api.device.getByModule("teleport_module")
    else
        for index, device_uuid in ipairs(allowed_devices) do
            table.insert(devices, backend.api.device.get(device_uuid))
        end
    end

    local online_devices = backend.api.device.getAllOnline()

    local buttons = {}
    local button_index = 0
    for _, device in ipairs(devices) do
        if table.includes(online_devices, device.device_uuid) then
            table.insert(buttons, button({
                x = 2, y = (button_index * 4) + 2, width = term.getSize() - 3, height = 2,
                text = device.name, onClick = function(self)
                    doTeleport(device.device_uuid)
                end
            }))
            button_index = button_index + 1
        end
    end

    return buttons
end

main()
