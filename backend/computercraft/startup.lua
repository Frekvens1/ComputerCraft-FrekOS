local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

shell.run("/frekos/startup.lua")

local function runShell()
    -- shell.run("/frekos/apps/lockscreen.lua")

    os.pullEvent = pullEvent
    if fs.exists("/custom_startup.lua") then
        shell.run("/rom/programs/shell.lua /custom_startup.lua")
    else
        shell.run("/rom/programs/shell.lua /frekos/apps/welcome_screen.lua")
    end
end

parallel.waitForAny(
        backgroundTasks.supervisor,
        runShell
)
