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

while true do
    if shouldDig() then
        dig()
        placeQuartz()
    end

    os.sleep(0.1)
end
