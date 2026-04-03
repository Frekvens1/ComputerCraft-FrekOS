local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local success, error = pcall(loadfile("/frekos/startup.lua", _ENV))

if not success then
    term.clear()
    term.setCursorPos(1,1)

    print("Startup failed to run:")
    print(error)
    print()

    local config_path = "/frekos/settings.conf"
    if not fs.exists(config_path) then
        print("=== Press a key to reboot ===")
        os.pullEvent("key")
        os.reboot()
    else
        print("=== Press a key to update ===")
        os.pullEvent("key")

        local file = fs.open(config_path, "r")
        local settings = textutils.unserialize(file.readAll())
        file.close()

        shell.run("wget run " .. settings.update_url .. " " .. settings.device_uuid)
        os.reboot()
    end
end

os.pullEvent = pullEvent

if fs.exists("/custom_startup.lua") then
    screen.clear()
    shell.run("/custom_startup.lua")
end

-- shell.run("/frekos/apps/lockscreen.lua")

if turtle then
    shell.run("/frekos/apps/turtle.lua")
end

shell.run("/frekos/apps/welcome_screen.lua")
