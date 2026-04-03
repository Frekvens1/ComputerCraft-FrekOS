local fuel = turtle.getFuelLevel()
local fuelMax = turtle.getFuelLimit()

while fuel ~= fuelMax do
    screen.clear()
    print("Turtle lava refill")
    screen.printLine()
    print()
    print("Progress: " .. ((fuel / fuelMax) * 100) .. "%")
    print("Fuel: " .. fuel .. " / " .. fuelMax)

    sleep(2)

    turtle.suck()
    turtle.refuel()
    turtle.drop()

    fuel = turtle.getFuelLevel()
end

screen.clear()
print("Turtle fuel reached max capacity!")
