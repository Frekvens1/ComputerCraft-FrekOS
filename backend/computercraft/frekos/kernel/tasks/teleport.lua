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
        coroutine.yield("frekos_teleport")
        toggleRedstone(trapdoor_side)
    end
end

if table.includes(frekos.device.modules, "teleport_module") then
    return task
end

return function()  end
