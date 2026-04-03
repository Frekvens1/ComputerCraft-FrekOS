screen.clear()

local status = "Offline"
if backendUtils.connection then
    status = "Online"
end

print("FrekOS v0.1 - " .. status)
