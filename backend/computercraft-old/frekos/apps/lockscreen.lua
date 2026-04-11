local password = "changeme"

local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

while true do
    screen.clear()
    print("Restricted access.\n")
    write("Password: ")

    local input = read("*")

    if input == password then
        break
    else
        print("\nInvalid password. Please try again.")
        sleep(1.2)
    end
end

os.pullEvent = pullEvent
screen.clear()
