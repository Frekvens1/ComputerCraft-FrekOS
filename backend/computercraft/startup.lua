shell.run("/frekos/apps/startup.lua")

-- shell.run("/frekos/apps/lockscreen.lua")

term.clear()
term.setCursorPos(1,1)

shell.run("/custom_startup.lua")
shell.run("/frekos/apps/welcome_screen.lua")
