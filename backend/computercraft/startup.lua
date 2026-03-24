shell.run("/frekos/startup.lua")

-- shell.run("/frekos/apps/lockscreen.lua")

screenUtils.clear()
shell.run("/custom_startup.lua")
shell.run("/frekos/apps/welcome_screen.lua")
