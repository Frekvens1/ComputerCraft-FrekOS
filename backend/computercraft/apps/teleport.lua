trapdoor_side = "front"

local function main()
    resetRedstone(trapdoor_side)

    FrekOS.events.addTask("teleport", function(event)
        if event[1] == "frekos_teleport" then
            toggleRedstone(trapdoor_side)
        end
    end)

    os.pullEventRaw("terminate")
    FrekOS.events.removeTask("teleport")
end

function resetRedstone(side)
    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

function toggleRedstone(side)
    redstone.setAnalogOutput(side, 0)
    os.sleep(1)
    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

main()
