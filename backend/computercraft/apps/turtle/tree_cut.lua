function main()
    screen.clear()
    print("Chopping down trees!")

    while true do
        local block_present, block = turtle.inspect()
        if not block_present then
            turtle.select(1)
            turtle.place()

        elseif not block.name:includes("sapling") then
            turtle.select(1)
            turtle.dig()
            turtle.place()
        end

        while turtle.suck() do
            os.sleep(0.5)
        end

        while turtle.suckUp() do
            os.sleep(0.5)
        end

        while turtle.suckDown() do
            os.sleep(0.5)
        end
    end
end

main()
