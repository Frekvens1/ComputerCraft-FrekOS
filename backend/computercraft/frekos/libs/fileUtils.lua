local api = {}

function api.saveConfig(path, variable)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(variable))
    file.close()
end

function api.loadConfig(path)
    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

function beforeLoad()

end

function afterLoad()

end

return api, beforeLoad, afterLoad
