-- region { private }

local api = {}

-- endregion

function api.read(path)
    if not api.exists(path) then
        return nil
    end

    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()

    return data
end

function api.write(path, text)
    local file = fs.open(path, "w")
    file.write(text)
    file.close()
end

function api.exists(path)
    return fs.exists(path)
end

function api.delete(path)
    if not api.exists(path) then
        return nil
    end

    fs.delete(path)
end

function api.saveConfig(path, variable)
    api.write(path, textutils.serialize(api.sanitize(variable)))
end

function api.loadConfig(path)
    return textutils.unserialize(api.read(path))
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
