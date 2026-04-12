-- region { private }

local api = {
    native = _G.turtle
}

local function updateInventory()
    -- storage.updateTurtleInventory()
end

-- endregion

-- region { native functions }

function api.isTurtle()
    return api.native ~= nil
end

function api.forward()
    local ok, err = api.native.forward()

    api.inspect()
    api.inspectUp()
    api.inspectDown()

    return ok, err
end

function api.back()
    local ok, err = api.native.back()

    api.inspect()
    api.inspectUp()
    api.inspectDown()

    return ok, err
end

function api.up()
    local ok, err = api.native.up()

    api.inspect()
    api.inspectUp()

    return ok, err
end

function api.down()
    local ok, err = api.native.down()

    api.inspect()
    api.inspectDown()

    return ok, err
end

function api.turnLeft()
    local ok, err = api.native.turnLeft()

    api.inspect()

    return ok, err
end

function api.turnRight()
    local ok, err = api.native.turnRight()

    api.inspect()

    return ok, err
end

function api.refuel(count)
    return api.native.refuel(count)
end

function api.getFuelLevel()
    return api.native.getFuelLevel()
end

function api.getFuelLimit()
    return api.native.getFuelLimit()
end

function api.attack()
    return api.native.attack()
end

function api.inspect()
    return api.native.inspect()
end

function api.inspectUp()
    return api.native.inspectUp()
end

function api.inspectDown()
    return api.native.inspectDown()
end

function api.detect()
    return api.native.detect()
end

function api.detectUp()
    return api.native.detectUp()
end

function api.detectDown()
    return api.native.detectDown()
end

function api.dig()
    return api.native.dig()
end

function api.digUp()
    return api.native.digUp()
end

function api.digDown()
    return api.native.digDown()
end

function api.place()
    return api.native.place()
end

function api.placeUp()
    return api.native.placeUp()
end

function api.placeDown()
    return api.native.placeDown()
end

function api.getItemCount()
    return api.native.getItemCount()
end

function api.drop(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.drop(count)
end

function api.dropUp(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.dropUp(count)
end

function api.dropDown(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.dropDown(count)
end

function api.suck(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.suck(count)
end

function api.suckUp(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.suckUp(count)
end

function api.suckDown(count)
    if count ~= nil then
        count = tonumber(count)
    end

    return api.native.suckDown(count)
end

function api.craft(count)
    if count ~= nil then
        count = tonumber(count)
    else
        count = 1
    end

    return api.native.craft(count)
end

function api.select(index)
    index = tonumber(index)
    if index == nil then
        index = 1
    end

    if index > 16 then
        index = 16
    end

    if index < 1 then
        index = 1
    end

    local ok, err = api.native.select(index)
    updateInventory()

    return ok, err
end

-- endregion

function api.refill(count)
    return api.refuel(count)
end

function api.fuel()
    return api.getFuelLevel()
end

function api.maxFuel()
    return api.getFuelLimit()
end

function api.buildRoof(...)
    os.run("/apps/turtle/build_roof.lua", ...)
end

function api.chunkMiner(...)
    os.run("/apps/turtle/chunk_miner.lua", ...)
end

if api.isTurtle() then
    return api
end
