local function dig()
    turtle.dig()
end

local function shouldDig()
    local success, data = turtle.inspect()
    if not success then return false end

    return data.name == "ae2:quartz_cluster"
end

local function depositInventory()
    turtle.dropDown()
end

while true do
    if shouldDig() then
        dig()
        depositInventory()
    end

    os.sleep(0.1)
end
