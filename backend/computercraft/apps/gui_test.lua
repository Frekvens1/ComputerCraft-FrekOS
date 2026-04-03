local input = gui.components.input
local button = gui.components.button

function main()
    gui.render(gui.createApp(createObjects()))
end

function createObjects()
    local objects = {}
    local times_clicked = 0
    table.insert(objects, button({
        x = 2, y = 2, width = term.getSize() - 3, height = 2,
        text = "Click me!", onClick = function(self, app)
            times_clicked = times_clicked + 1
            self.text = "Clicked " .. times_clicked .. " times!"
        end
    }))

    table.insert(objects, input({
        x = 2, y = 6, width = term.getSize() - 3, height = 0,
        text = "Write here!", onChange = function(self, app, text)
            backendUtils.send({
                onChange = text
            })
        end
    }))

    return objects
end

main()