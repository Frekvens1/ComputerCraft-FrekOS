local args = {...}
local x_blocks = args[1]

if x_blocks == nil then
    x_blocks = "3"
end

local whitelisted_blocks = {
    "minecraft:torch"
}

function main()
    screen.clear()
    print("Mining a tunnel '" .. x_blocks .. "' wide...")

    while true do
        if x_blocks == "1" then
            doDig()
        else
            mineRight()
            mineLeft()
        end
    end
end

function dig()
    while true do
        local hasBlock, block = turtle.inspect()
        if not hasBlock or (block and table.includes(whitelisted_blocks, block.name)) then
            break
        end

        turtle.dig()
        sleep(0.1)
    end
end

function digUp()
    while true do
        local hasBlock, block = turtle.inspectUp()
        if not hasBlock or (block and table.includes(whitelisted_blocks, block.name)) then
            break
        end

        turtle.digUp()
        sleep(0.1)
    end
end

function digDown()
    while true do
        local hasBlock, block = turtle.inspectDown()
        if not hasBlock or (block and table.includes(whitelisted_blocks, block.name)) then
            break
        end

        turtle.digDown()
    end
end

function doDig()
    dig()
    turtle.forward()
    digUp()
    digDown()
end

function mineRight()
    doDig()

    turtle.turnRight()
    for x = 1, x_blocks - 1 do
        doDig()
    end
    turtle.turnLeft()
end

function mineLeft()
    doDig()

    turtle.turnLeft()
    for x = 1, x_blocks - 1 do
        doDig()
    end
    turtle.turnRight()
end

main()
screen.clear()
