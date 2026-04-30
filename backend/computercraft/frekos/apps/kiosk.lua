os.pullEvent = os.pullEventRaw
local button = gui.components.button

local should_reboot = true

function main()
    gui.render(gui.createApp(createObjects()))
end

function createObjects()
    local objects = {}
    local term_width, term_height = term.getSize()
    table.insert(objects, button({
        x = 2, y = 2, width = term_width - 3, height = 2,
        text = "Update", onClick = function(self, app)
            os.run("/frekos/apps/update.lua")
        end
    }))

    table.insert(objects, button({
        x = 2, y = 6, width = term_width - 3, height = 2,
        text = "Reboot", onClick = function(self, app)
            os.reboot()
        end
    }))

    if frekos.device.use_lockscreen then
        table.insert(objects, button({
            x = 2, y = term_height - 3, width = term_width - 3, height = 2,
            text = "Maintenance", onClick = function(self, app)
                os.run("/frekos/apps/lockscreen.lua")
                os.queueEvent("terminate")
                should_reboot = false
            end
        }))
    end

    return objects
end

main()

if should_reboot then
    os.reboot()
end
