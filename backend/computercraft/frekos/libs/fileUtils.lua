-- region { private }

local api = {}

-- endregion

function api.saveConfig(path, variable)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(sanitize(variable)))
    file.close()
end

function api.loadConfig(path)
    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

function api.sanitize(value)
    if type(value) == "function" then
        return nil
    elseif type(value) == "table" then
        local out = {}
        for k, v in pairs(value) do
            if type(v) ~= "function" then
                out[k] = api.sanitize(v)
            end
        end
        return out
    else
        return value
    end
end

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
