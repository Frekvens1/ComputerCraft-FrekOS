trapdoor_side = "front"

function main()
    resetRedstone(trapdoor_side)
    while true do
        local msg = backendUtils.connection.receive()
        if msg then
            toggleRedstone(trapdoor_side)
        end
    end
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
