local button = gui.components.button

function main()
    gui.render(gui.createApp(quickApps()))
end

function quickApps()
    local objects = {}

    local programs = {
        { name = "Lava refill", file_path = "/apps/turtle/lava_refill.lua" },
        { name = "Mine tunnel (3 x 3)", file_path = "/apps/turtle/tunnel_miner.lua" },
        { name = "Mine chunk (16 x 16 x 256)", file_path = "/apps/turtle/chunk_miner.lua" },
        { name = "Quartz miner", file_path = "/apps/turtle/quartz_miner.lua" },
        { name = "Quartz replacer", file_path = "/apps/turtle/quartz_replacer.lua" },
    }

    table.insert(objects, button({
            x = 2, y = 2, width = term.getSize() - 3, height = 0,
            text = "Exit", onClick = function(self, app, x, y)
                os.queueEvent("terminate")
            end
        }))

    for index, program in ipairs(programs) do
        table.insert(objects, button({
            x = 2, y = 2 * index + 2, width = term.getSize() - 3, height = 0,
            text = program.name, onClick = function(self, app, x, y)
                os.run(program.file_path)
                os.queueEvent("terminate")
            end
        }))
    end

    return objects
end

main()
