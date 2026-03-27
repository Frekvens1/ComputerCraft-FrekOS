local fuel = turtle.getFuelLevel()
local fuelMax = turtle.getFuelLimit()

while fuel ~= fuelMax do
    screenUtils.clear()
    print("Turtle lava refill")
    screenUtils.printLine()
    print()
    print("Progress: " .. ((fuel / fuelMax) * 100) .. "%")
    print("Fuel: " .. fuel .. " / " .. fuelMax)

    sleep(2)

    turtle.suck()
    turtle.refuel()
    turtle.drop()

    fuel = turtle.getFuelLevel()
end

screenUtils.clear()
print("Turtle fuel reached max capacity!")
