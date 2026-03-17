local password = "changeme"

function onSuccess()
    shell.run("/frekos/apps/welcome_screen.lua")
end

function onFailure()
    print()
    print("Invalid password. Please try again.")
end

function onRetry()
    print("Restricted access.")
    print()
    write("Password: ")
end

function clear()
   term.clear()
   term.setCursorPos(1,1)
end

local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

while true do
   clear()
   onRetry()
   local input = read("*")

   if input == password then
       break
   else
       onFailure()
       sleep(1.2)
   end
end

os.pullEvent = pullEvent

clear()
onSuccess()
