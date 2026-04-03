local button = gui.components.button

function main()
    gui.render(gui.createApp(createObjects()))
end

function createObjects()
    local objects = {}
    local times_clicked = 0
    table.insert(objects, button(2, 2, term.getSize() - 3, 2, "Click me!", function(self, app)
        times_clicked = times_clicked + 1
        self.text = "Clicked " .. times_clicked .. " times!"
    end))

    return objects
end

main()