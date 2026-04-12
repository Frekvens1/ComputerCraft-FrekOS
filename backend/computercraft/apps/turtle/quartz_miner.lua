local function shouldDig()
    local success, data = turtle.inspect()
    if not success then return false end
    return data.name == "ae2:quartz_cluster"
end

local count = 0
while true do
    screen.clear()
    print("Quartz miner - Count: " .. count)
    screen.printLine()

    if shouldDig() then
        turtle.dig()
        turtle.dropDown()
        count = count + 1
    end

    os.sleep(0.2)
end
