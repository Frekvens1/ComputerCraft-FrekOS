_G.loadfile = function(path)
    local file = fs.open(path, "r")
    if not file then
        return nil, "File not found"
    end
    local data = file.readAll()
    file.close()
    return load(data, "@" .. path, "t", _G)
end

_G.dofile = function(path)
    local fn, load_error = loadfile(path)
    if not fn then
        return nil, load_error
    end

    local results = { pcall(fn) }
    if not results[1] then
        return nil, results[2]
    end

    return table.unpack(results, 2)
end

_G.dofileSandbox = function(path)
    local env = {}
    env._ENV = env
    setmetatable(env, { __index = table.deepCopy(_G) })

    local fn, load_error = loadfile(path)
    if not fn then
        return nil, load_error
    end

    setfenv(fn, env)

    local results = { pcall(fn) }
    if not results[1] then
        return nil, results[2]
    end

    return table.unpack(results, 2)
end

local loaded = {}
local require_paths = {
    "/rom/modules/main/",
}

_G.require = function(name)
    if loaded[name] then
        return loaded[name]
    end

    local rel = name:gsub("%.", "/") .. ".lua"
    local fn, err

    for _, base in ipairs(require_paths) do
        local path = base .. rel
        fn, err = loadfile(path)
        if fn then
            break
        end
    end

    if not fn then
        error("Module not found: " .. name .. "\n" .. err)
    end

    local result = fn()

    loaded[name] = result or true

    return result
end

