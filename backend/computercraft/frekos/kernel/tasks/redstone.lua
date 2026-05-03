local function task()
    local state = fs.loadConfig("/frekos/config/state.conf")
    if state and state.redstone then
        for side, redstone_state in pairs(state.redstone) do
            if redstone_state.mode == "output" then
                redstone.setAnalogOutput(side, redstone_state.power)
            end
        end
    end

    while true do
        local event = { coroutine.yield("frekos_redstone") }
        local redstone_task = event[2]
        local side = event[3]

        if redstone_task == "output" then
            local power = event[4]
            if power ~= nil then
                power = tonumber(power)
                if power > 15 then
                    power = 15
                elseif power < 0 then
                    power = 0
                end
            else
                power = 0
            end

            redstone.setAnalogOutput(side, power)
            frekos.updateState()
        end

    end
end

return task
