-- region { private }

local api = {
    native = _G.redstone
}

-- endregion

-- region { native functions }

function api.getSides()
    return api.native.getSides()
end

function api.setOutput(side, on)
    return api.native.setOutput(side, on)
end

function api.getOutput(side)
    return api.native.getOutput(side)
end

function api.getInput(side)
    return api.native.getInput(side)
end

function api.setAnalogOutput(side, value)
    return api.native.setAnalogOutput(side, value)
end

function api.setAnalogueOutput(side, value)
    return api.setAnalogOutput(side, value)
end

function api.getAnalogOutput(side)
    return api.native.getAnalogOutput(side)
end

function api.getAnalogueOutput(side)
    return api.getAnalogOutput(side)
end

function api.getAnalogInput(side)
    return api.native.getAnalogInput(side)
end

function api.getAnalogueInput(side)
    return api.getAnalogInput(side)
end

function api.setBundledOutput(side, output)
    return api.native.setBundledOutput(side, output)
end

function api.getBundledOutput(side)
    return api.native.getBundledOutput(side)
end

function api.getBundledInput(side)
    return api.native.getBundledInput(side)
end

function api.testBundledInput(side, mask)
    return api.native.testBundledInput(side, mask)
end

-- endregion

return api
