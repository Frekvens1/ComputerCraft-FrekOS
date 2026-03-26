-- region { private }

local api = {}

-- endregion

function api.isTurtle()
    return turtle ~= nil
end

function api.forward()
    turtle.forward()

    api.inspect()
    api.inspectUp()
    api.inspectDown()
end

function api.back()
    turtle.back()

    api.inspect()
    api.inspectUp()
    api.inspectDown()
end

function api.up()
    turtle.up()

    api.inspect()
    api.inspectUp()
end

function api.down()
    turtle.down()

    api.inspect()
    api.inspectDown()
end

function api.turnLeft()
    turtle.turnLeft()

    api.inspect()
end

function api.turnRight()
    turtle.turnRight()

    api.inspect()
end

function api.refuel()
    turtle.getFuelLevel()
end

function api.fuel()
    turtle.getFuelLevel()
end

function api.maxFuel()
    turtle.getFuelLimit()
end

function api.attack()
    turtle.attack()
end

function api.inspect()
    return turtle.inspect()
end

function api.inspectUp()
    return turtle.inspectUp()
end

function api.inspectDown()
    return turtle.inspectDown()
end

function api.dig()
    turtle.dig()
end

function api.digUp()
    turtle.digUp()
end

function api.digDown()
    turtle.digDown()
end

-- getSelectedSlot
-- getItemSpace
-- getItemDetail
-- getItemCount
-- transferTo
-- suckUp
-- suckDown
-- suck
-- drop
-- dropUp
-- dropDown
-- select
-- placeUp
-- placeDown
-- place
-- equipLeft

local function beforeLoad()

end

local function afterLoad()
    FrekOS.events.addTask("remote_turtle", function(event)
        if event[1] ~= "frekos_turtle" then
            return
        end

        local task = event[2]
        if api[task] ~= nil then
            api[task](event)
        end
    end)
end

if api.isTurtle() then
    return api, beforeLoad, afterLoad
end
