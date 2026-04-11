if FrekOS == nil then
    local path = "/frekos/settings.conf"
    if not fs.exists(path) then
        return nil
    end

    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()

    FrekOS = {
        settings = textutils.unserialize(data)
    }
end

shell.run("wget run " .. FrekOS.settings.update_url .. " " .. FrekOS.settings.device_uuid)
