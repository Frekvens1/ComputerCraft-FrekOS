-- region { private }

local api = {}

-- endregion

function api.getDevices()
    return backendUtils.get("/devices")
end

function api.getDevicesOnline()
    return backendUtils.get("/devices/online")
end

function api.getDevicesByType(device_type)
    return backendUtils.get("/devices/type/" .. device_type)
end

function api.getDevice(device_uuid)
    return backendUtils.get("/device/" .. device_uuid)
end

function api.getDeviceOnline(device_uuid)
    return backendUtils.get("/device/" .. device_uuid .. "/online")
end

api.events = {}

function api.events.teleport(device_uuid)
    return backendUtils.get("/device/" .. device_uuid .. "/events/teleport")
end

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
