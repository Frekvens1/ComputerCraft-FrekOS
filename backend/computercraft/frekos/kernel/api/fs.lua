-- region { private }

local api = {
    native = _G.fs
}

-- endregion

-- region { native functions }

function api.complete(...)
    return api.native.complete(...)
end

function api.find(path)
    return api.native.find(path)
end

function api.isDriveRoot(path)
    return api.native.isDriveRoot(path)
end

function api.list(path)
    return api.native.list(path)
end

function api.combine(path, ...)
    return api.native.combine(path, ...)
end

function api.getName(path)
    return api.native.getName(path)
end

function api.getDir(path)
    return api.native.getDir(path)
end

function api.getSize(path)
    return api.native.getSize(path)
end

function api.exists(path)
    return api.native.exists(path)
end

function api.isDir(path)
    return api.native.isDir(path)
end

function api.isReadOnly(path)
    return api.native.isReadOnly(path)
end

function api.makeDir(path)
    return api.native.makeDir(path)
end

function api.move(path, dest)
    return api.native.move(path, dest)
end

function api.copy(path, dest)
    return api.native.copy(path, dest)
end

function api.delete(path)
    return api.native.delete(path)
end

function api.open(path, mode)
    return api.native.open(path, mode)
end

function api.getDrive(path)
    return api.native.getDrive(path)
end

function api.getFreeSpace(path)
    return api.native.getFreeSpace(path)
end

function api.getCapacity(path)
    return api.native.getCapacity(path)
end

function api.attributes(path)
    return api.native.attributes(path)
end

-- endregion

function api.read(path, bytes)
    local mode = "r"
    if bytes then
        mode = "rb"
    end

    local file, err = api.native.open(path, mode)
    if not file then
        return nil, err
    end

    local data = file.readAll()
    file.close()

    return data
end

function api.write(path, content, bytes)
    local mode = "w"
    if bytes then
        mode = "wb"
    end

    local file, err = api.native.open(path, mode)
    if not file then
        return nil, err
    end

    file.write(content)
    file.close()
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
    for _, file in ipairs(api.native.list(folder_path)) do
        local file_path = api.native.combine(folder_path, file)
        if file:match("%.lua$") then
            local name = file:gsub("%.lua$", "")
            result[name] = api.loadFile(file_path)
        end
    end

    return result
end

function api.loadFile(file_path, ...)
    if not api.native.exists(file_path) then
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

    setfenv(fn, env)

    local result = { pcall(fn, ...) }
    if not result[1] then
        return result[1], result[2]
    end

    return table.unpack(result, 2, #result)
end

return api
