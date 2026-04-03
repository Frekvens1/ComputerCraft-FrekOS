local args = { ... }

local tunnel_width = tonumber(args[1])
local tunnel_length = tonumber(args[2])
local tunnel_height = tonumber(args[3])

if tunnel_width == nil then
    tunnel_width = 16
end

if tunnel_length == nil then
    tunnel_length = 16
end

if tunnel_height == nil then
    tunnel_height = 256
end

local blocks_mined = 0
local volume_checked = 0
local volume_above_area = tunnel_width * tunnel_length * 2
local volume_inside_area = tunnel_width * tunnel_length * tunnel_height
local volume_to_check = volume_inside_area + volume_above_area

function printProgress()
    screen.clear()
    print("FrekOS Chunk Miner - In progress...")
    screen.printLine()
    print("Progress complete: " .. math.floor((volume_checked / volume_to_check) * 100 + 0.5) .. "%")
    print()
    print("Volume checked: " .. volume_checked .. " / " .. volume_to_check)
    print("Blocks mined: " .. blocks_mined)
    print()
    print("Volume above area: " .. volume_above_area)
    print("Volume inside area: " .. volume_inside_area)
    print()
    print("Mining width: " .. tunnel_width)
    print("Mining length: " .. tunnel_length)
    write("Mining height: " .. tunnel_height)
end

function printFinished()
    screen.clear()
    print("FrekOS Chunk Miner - Finished!")
    screen.printLine()
    print("Volume checked: " .. volume_checked .. " / " .. volume_to_check)
    print("Blocks mined: " .. blocks_mined)
    print()
    print("Volume above area: " .. volume_above_area)
    print("Volume inside area: " .. volume_inside_area)
    print()
    print("Mining width: " .. tunnel_width)
    print("Mining length: " .. tunnel_length)
    print("Mining height: " .. tunnel_height)
    print()
end

printProgress()

local do_dig_up = true
local do_dig_front = true

function main()

    doDig()

    local y = 1
    local reverse_x = false
    while y <= tunnel_height do
        for x = 1, tunnel_width do
            for z = 1, tunnel_length - 1 do
                doDig()
            end

            if x < tunnel_width then
                if reverse_x then
                    turtle.turnLeft()
                    doDig()
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                    doDig()
                    turtle.turnRight()
                end
            end

            reverse_x = not reverse_x
        end

        if y < tunnel_height then
            do_dig_up = true
            do_dig_front = true
            for sub_y = 1, 3 do
                if y >= tunnel_height then
                    if sub_y == 2 then
                        do_dig_front = false
                    end
                    do_dig_up = false
                    break
                end

                y = y + 1

                turtle.down()
                digDown()
            end

            y = y - 1

            turtle.turnRight()
            turtle.turnRight()

            reverse_x = not reverse_x
        end

        y = y + 1
    end
end

function dig()
    while true do
        local hasBlock, block = turtle.inspect()
        if not hasBlock or block.name == "minecraft:torch" then
            break
        end

        turtle.dig()
        blocks_mined = blocks_mined + 1
        sleep(0.1)
    end

    volume_checked = volume_checked + 1
    printProgress()
end

function digUp()
    while true do
        local hasBlock, block = turtle.inspectUp()
        if not hasBlock or block.name == "minecraft:torch" then
            break
        end

        turtle.digUp()
        blocks_mined = blocks_mined + 1
        sleep(0.1)
    end

    volume_checked = volume_checked + 1
    printProgress()
end

function digDown()
    while true do
        local hasBlock, block = turtle.inspectDown()
        if not hasBlock or block.name == "minecraft:torch" then
            break
        end

        turtle.digDown()
        blocks_mined = blocks_mined + 1
    end

    volume_checked = volume_checked + 1
    printProgress()
end

function doDig()
    if do_dig_front then
        dig()
    end

    turtle.forward()
    if do_dig_up then
        digUp()
    end
    digDown()
end

parallel.waitForAny(function()
    os.pullEventRaw("terminate")
end, main)

printFinished()
term.write("=== Press a key to continue ===")
os.pullEvent("key")
screen.clear()
