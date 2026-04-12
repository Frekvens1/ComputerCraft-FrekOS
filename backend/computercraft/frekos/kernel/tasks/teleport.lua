local trapdoor_side = "front"

local function resetRedstone(side)
    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

local function toggleRedstone(side)
    redstone.setAnalogOutput(side, 0)
    os.sleep(1)

    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

local function task()
    resetRedstone(trapdoor_side)

    while true do
        local event = coroutine.yield()

        if event == "frekos_teleport" then
            toggleRedstone(trapdoor_side)
        end
    end
end

return task
