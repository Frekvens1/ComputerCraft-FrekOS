local button = gui.components.button

function main()
    local app = gui.createApp(refreshDevices())
    gui.render(app)
end

function doTeleport(device_uuid)
    FrekOS.api.device.events.teleport(device_uuid)
end

function refreshDevices()
    local devices = FrekOS.api.device.getByType("teleport_module")
    local online_devices = FrekOS.api.device.getAllOnline()

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
