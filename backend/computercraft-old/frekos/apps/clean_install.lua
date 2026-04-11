local function wipeRoot()
    for _, item in ipairs(fs.list("/")) do
        if item ~= "rom" and item ~= "disk" then
            fs.delete("/" .. item)
        end
    end
end

local env = setmetatable({}, { __index = _ENV })
env.shell = shell

local update_function = loadfile("/frekos/apps/update.lua", env)

wipeRoot()
update_function()
