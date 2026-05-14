local function task()
    local state = fs.loadConfig("/frekos/config/state.conf")
    if state ~= nil and state.redstone ~= nil then
        for side, redstone_state in pairs(state.redstone) do
            if redstone_state.mode == "output" then
                redstone.setAnalogOutput(side, redstone_state.power)
            end
        end
    end

    while true do
        local event = { coroutine.yield("frekos_redstone") }
        local _, redstone_device, redstone_task, side, power = table.unpack(event)

        if redstone_task == "output" then
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

            if redstone_device == "device" then
                redstone.setAnalogOutput(side, power)
            else
                local rs_peripheral = peripheral.wrap(redstone_device)
                if rs_peripheral ~= nil then
                    rs_peripheral.setAnalogOutput(side, power)
                end
            end

            frekos.updateState()
        end

    end
end

return task
