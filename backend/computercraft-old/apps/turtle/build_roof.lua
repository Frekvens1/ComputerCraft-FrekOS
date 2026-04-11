local args = { ... }

local roof_width = tonumber(args[1])
local roof_length = tonumber(args[2])

if roof_width == nil then
    roof_width = 16
end

if roof_length == nil then
    roof_length = 16
end

local reverse_x = false

local current_slot = 1
local needs_refill = false

function main()
    turtle.select(current_slot)
    for x = 1, roof_width do
        for z = 1, roof_length - 1 do
            doTask()
        end

        if x < roof_width then
            if reverse_x then
                turtle.turnLeft()
                doTask()
                turtle.turnLeft()
            else
                turtle.turnRight()
                doTask()
                turtle.turnRight()
            end
        end

        reverse_x = not reverse_x
    end

    doTask()
end

function doTask()
    while not turtle.detectUp() do
        local item_count = turtle.getItemCount(current_slot)
        while item_count == 0 do
            if needs_refill then
                sleep(1)
            else
                current_slot = current_slot + 1
                if current_slot == 17 then
                    current_slot = 1
                    needs_refill = true
                end

                turtle.select(current_slot)
            end

            item_count = turtle.getItemCount(current_slot)
        end

        needs_refill = false
        turtle.placeUp()
    end
    turtle.forward()
end

main()
