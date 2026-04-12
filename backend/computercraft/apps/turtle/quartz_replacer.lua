local function shouldDig()
    local success, data = turtle.inspect()
    if not success then return false end

    return data.name == "ae2:quartz_block"
end

local function dig()
    turtle.select(16)
    turtle.dig()
    turtle.dropDown()
end

local function placeQuartz()
    turtle.select(1)
    turtle.place()
end

local count = 0
while true do
    screen.clear()
    print("Quartz replacer - Count: " .. count)
    screen.printLine()

    if shouldDig() then
        dig()
        placeQuartz()
        count = count + 1
    end

    os.sleep(1)
end
