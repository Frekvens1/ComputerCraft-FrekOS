local function wipeRoot()
    for _, item in ipairs(fs.list("/")) do
        if item ~= "rom" and item ~= "disk" then
            fs.delete("/" .. item)
        end
    end
end

pcall(function()
    backend.api.device.deleteState(frekos.device.device_uuid)
end)

wipeRoot()
os.setComputerLabel()
os.reboot()
