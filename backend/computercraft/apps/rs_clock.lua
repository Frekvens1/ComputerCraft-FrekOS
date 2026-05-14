local args = { ... }
if #args == 0 then
    error("Missing argument for clock config", 0)
end

local clock = args[1]

-- Program argument example (Used in singleplayer).
--[[
local clock = {
    minute_0 = {
        top = { name = "redstone_relay_2", side = "top" },
        top_left = { name = "redstone_relay_2", side = "right" },
        top_right = { name = "redstone_relay_2", side = "left" },
        middle = { name = "redstone_relay_2", side = "bottom" },
        bottom_left = { name = "redstone_relay_1", side = "right" },
        bottom_right = { name = "redstone_relay_1", side = "left" },
        bottom = { name = "redstone_relay_1", side = "bottom" },
    },
    minute_1 = {
        top = { name = "redstone_relay_4", side = "top" },
        top_left = { name = "redstone_relay_4", side = "right" },
        top_right = { name = "redstone_relay_4", side = "left" },
        middle = { name = "redstone_relay_4", side = "bottom" },
        bottom_left = { name = "redstone_relay_3", side = "right" },
        bottom_right = { name = "redstone_relay_3", side = "left" },
        bottom = { name = "redstone_relay_3", side = "bottom" },
    },
    delimiter_mh = {
        top = { name = "redstone_relay_0", side = "right" },
        bottom = { name = "redstone_relay_0", side = "bottom" },
    },
    hour_0 = {
        top = { name = "redstone_relay_6", side = "top" },
        top_left = { name = "redstone_relay_6", side = "right" },
        top_right = { name = "redstone_relay_6", side = "left" },
        middle = { name = "redstone_relay_6", side = "bottom" },
        bottom_left = { name = "redstone_relay_5", side = "right" },
        bottom_right = { name = "redstone_relay_5", side = "left" },
        bottom = { name = "redstone_relay_5", side = "bottom" },
    },
    hour_1 = {
        top = { name = "redstone_relay_8", side = "top" },
        top_left = { name = "redstone_relay_8", side = "right" },
        top_right = { name = "redstone_relay_8", side = "left" },
        middle = { name = "redstone_relay_8", side = "bottom" },
        bottom_left = { name = "redstone_relay_7", side = "right" },
        bottom_right = { name = "redstone_relay_7", side = "left" },
        bottom = { name = "redstone_relay_7", side = "bottom" },
    },
}
]]--

local states = {
    minute_0 = { last = -1, current = -1, display = {} },
    minute_1 = { last = -1, current = -1, display = {} },
    hour_0 = { last = -1, current = -1, display = {} },
    hour_1 = { last = -1, current = -1, display = {} },
}

local function main()
    while true do
        local time = textutils.formatTime(os.time(), true)
        if #time == 4 then
            time = "0" .. time
        end

        local h1, h0, m1, m0 = time:match("(%d)(%d):(%d)(%d)")

        states.minute_0.current = tonumber(m0)
        states.minute_1.current = tonumber(m1)
        states.hour_0.current = tonumber(h0)
        states.hour_1.current = tonumber(h1)

        if states.minute_0.current ~= states.minute_0.last then
            displayNumber(clock.minute_0, states.minute_0)
            states.minute_0.last = states.minute_0.current
        end

        if states.minute_1.current ~= states.minute_1.last then
            displayNumber(clock.minute_1, states.minute_1)
            states.minute_1.last = states.minute_1.current
        end

        if states.hour_0.current ~= states.hour_0.last then
            displayNumber(clock.hour_0, states.hour_0)
            states.hour_0.last = states.hour_0.current
        end

        if states.hour_1.current ~= states.hour_1.last then
            displayNumber(clock.hour_1, states.hour_1)
            states.hour_1.last = states.hour_1.current
        end

        os.sleep(0)
    end
end

function displayNumber(display, state)
    local number_dict = getNumberDict(state.current)

    for segment, _ in pairs(state.display) do
        local info = display[segment]
        peripheral.get(info.name).setAnalogOutput(info.side, 0)
    end

    os.sleep(0.1)

    for segment, _ in pairs(number_dict) do
        local info = display[segment]
        peripheral.get(info.name).setAnalogOutput(info.side, 15)
    end

    state.display = number_dict
end

function setDelimiterLight(bOn)
    local top = clock.delimiter_mh.top
    local bottom = clock.delimiter_mh.bottom
    local power = 0
    if bOn then
        power = 15
    end

    peripheral.get(top.name).setAnalogOutput(top.side, power)
    peripheral.get(bottom.name).setAnalogOutput(bottom.side, power)
end

function getNumberDict(number)
    if number == 0 then
        return {
            top = true,
            top_left = true,
            top_right = true,
            bottom_left = true,
            bottom_right = true,
            bottom = true,
        }
    elseif number == 1 then
        return {
            top_right = true,
            bottom_right = true,
        }
    elseif number == 2 then
        return {
            top = true,
            top_right = true,
            middle = true,
            bottom_left = true,
            bottom = true,
        }
    elseif number == 3 then
        return {
            top = true,
            top_right = true,
            middle = true,
            bottom_right = true,
            bottom = true,
        }
    elseif number == 4 then
        return {
            top_left = true,
            top_right = true,
            middle = true,
            bottom_right = true,
        }
    elseif number == 5 then
        return {
            top = true,
            top_left = true,
            middle = true,
            bottom_right = true,
            bottom = true,
        }
    elseif number == 6 then
        return {
            top = true,
            top_left = true,
            middle = true,
            bottom_left = true,
            bottom_right = true,
            bottom = true,
        }
    elseif number == 7 then
        return {
            top = true,
            top_left = true,
            top_right = true,
            bottom_right = true,
        }
    elseif number == 8 then
        return {
            top = true,
            top_left = true,
            top_right = true,
            middle = true,
            bottom_left = true,
            bottom_right = true,
            bottom = true,
        }
    elseif number == 9 then
        return {
            top = true,
            top_left = true,
            top_right = true,
            middle = true,
            bottom_right = true,
            bottom = true,
        }
    else
        return {}
    end
end

setDelimiterLight(true)

main()

states.minute_0.current = -1
states.minute_1.current = -1
states.hour_0.current = -1
states.hour_1.current = -1

displayNumber(clock.minute_0, states.minute_0)
displayNumber(clock.minute_1, states.minute_1)
displayNumber(clock.hour_0, states.hour_0)
displayNumber(clock.hour_1, states.hour_1)

setDelimiterLight(false)
