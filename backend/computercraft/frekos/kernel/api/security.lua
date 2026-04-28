-- region { private }

local api = {}

-- endregion

function api.init()
    for name, fn in pairs(fs.loadFolder("/frekos/kernel/api/security")) do
        api[name] = fn
    end
end

function api.checkPassword(password)
    local hash = api.sha256(frekos.device.password_salt .. password)
    return hash == frekos.device.password
end

return api
