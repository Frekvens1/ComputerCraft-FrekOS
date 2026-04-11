os.pullEvent = os.pullEventRaw
local button = gui.components.button

function main()
    gui.render(gui.createApp(createObjects()))
end

function createObjects()
    local objects = {}
    table.insert(objects, button({
        x = 2, y = 2, width = term.getSize() - 3, height = 2,
        text = "Update", onClick = function(self, app)
            shell.run("/frekos/apps/update.lua")
        end
    }))

    table.insert(objects, button({
        x = 2, y = 6, width = term.getSize() - 3, height = 2,
        text = "Reboot", onClick = function(self, app)
            os.reboot()
        end
    }))

    return objects
end

main()
os.reboot()
