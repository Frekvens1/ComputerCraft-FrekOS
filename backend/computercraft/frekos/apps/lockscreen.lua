local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

while frekos.device.use_lockscreen do
    screen.clear()
    print("Restricted access.\n")
    write("Password: ")

    local input = read("*")

    if security.checkPassword(input) then
        break
    else
        print("\n\nInvalid password.\nPlease try again.")
        sleep(1.2)
    end
end

os.pullEvent = pullEvent
screen.clear()
