local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

while frekos.device.use_lockscreen do
    local ok, success = pcall(function()
        screen.clear()
        print("Restricted access.\n")
        write("Password: ")

        local input = read("*")

        if security.checkPassword(input) then
            return true
        else
            print("\n\nInvalid password.\nPlease try again.")
            sleep(1.2)
            return false
        end
    end)

    if ok and success then
        break
    end
end

os.pullEvent = pullEvent
screen.clear()
