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
