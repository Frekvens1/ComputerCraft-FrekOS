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

function api.loadFolder(folder_path)
    local result = {}
    for _, file in ipairs(fs.list(folder_path)) do
        local file_path = fs.combine(folder_path, file)
        if file:match("%.lua$") then
            local name = file:gsub("%.lua$", "")
            result[name] = api.loadfile(file_path)
        end
    end

    return result
end

function api.loadfile(file_path, ...)
    if not fs.exists(file_path) then
        return nil
    end

    local okLoad, fn = pcall(loadfile, file_path)
    if not okLoad then
        return nil, fn
    end

    return api.load(fn, ...)
end

function api.load(fn, ...)
    local env = {}
    env._ENV = env
    setmetatable(env, { __index = _ENV })
    env.shell = shell

    setfenv(fn, env)

    local result = { pcall(fn, ...) }
    if not result[1] then
        return result[1], result[2]
    end

    return table.unpack(result, 2, #result)
end

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
