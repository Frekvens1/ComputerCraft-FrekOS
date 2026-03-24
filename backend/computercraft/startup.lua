local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local success, error = pcall(loadfile("/frekos/startup.lua", _ENV))

if not success then
    term.clear()
    term.setCursorPos(1,1)

    print("Startup failed to run:")
    print(error)
    print()

    print("=== Press a key to reboot ===")

    os.pullEvent("key")
    os.reboot()
end

os.pullEvent = pullEvent

if fs.exists("/custom_startup.lua") then
    shell.run("/custom_startup.lua")
end

-- shell.run("/frekos/apps/lockscreen.lua")
shell.run("/frekos/apps/welcome_screen.lua")
