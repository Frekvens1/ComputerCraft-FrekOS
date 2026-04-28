-- region { private }

local api = {
    native = _G.turtle
}

local function updateInventory()
    storage.updateTurtleInventory()
end

-- endregion

-- region { native functions }

function api.craft(count)
    if count ~= nil then
        count = tonumber(count)
    else
        count = 1
    end

    return api.native.craft(count)
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

function api.dig(side)
    return api.native.dig(side)
end

function api.digUp(side)
    return api.native.digUp(side)
end

function api.digDown(side)
    return api.native.digDown(side)
end

function api.place(text)
    return api.native.place(text)
end

function api.placeUp(text)
    return api.native.placeUp(text)
end

function api.placeDown(text)
    return api.native.placeDown(text)
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

    local count = api.native.select(index)
    updateInventory()

    return count
end

function api.getItemCount(slot)
    return api.native.getItemCount(slot)
end

function api.getItemSpace(slot)
    return api.native.getItemSpace(slot)
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

function api.compare()
    return api.native.compare()
end

function api.compareUp()
    return api.native.compareUp()
end

function api.compareDown()
    return api.native.compareDown()
end

function api.attack(side)
    return api.native.attack(side)
end

function api.attackUp(side)
    return api.native.attackUp(side)
end

function api.attackDown(side)
    return api.native.attackDown(side)
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

function api.getFuelLevel()
    return api.native.getFuelLevel()
end

function api.refuel(count)
    count = tonumber(count)
    return api.native.refuel(count)
end

function api.compareTo(slot)
    slot = tonumber(slot)
    return api.native.compareTo(slot)
end

function api.transferTo(slot, count)
    slot = tonumber(slot)
    count = tonumber(count)
    return api.native.transferTo(slot, count)
end

function api.getSelectedSlot()
    return api.native.getSelectedSlot()
end

function api.getFuelLimit()
    return api.native.getFuelLimit()
end

function api.equipLeft()
    return api.native.equipLeft()
end

function api.equipRight()
    return api.native.equipRight()
end

function api.getEquippedLeft()
    return api.native.getEquippedLeft()
end

function api.getEquippedRight()
    return api.native.getEquippedRight()
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

function api.getItemDetail(slot, detailed)
    return api.native.getItemDetail(slot, detailed)
end

-- endregion

function api.isTurtle()
    return api.native ~= nil
end

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
