-- region { private }

local api = {}

-- endregion


-- region { string overwrites }


-- endregion


-- region { table overwrites }

function table.compare(self, value)
    if not self or not value then
        return false
    end

    if #self ~= #value then
        return false
    end

    for i = 1, #self do
        if self[i] ~= value[i] then
            return false
        end
    end

    return true
end

function table.includes(self, item)
    for i = 1, #self do
        if self[i] == item then
            return true, i
        end
    end

    return false, 0
end

function table.removeValue(self, item)
    local found, i = table.includes(self, item)
    if found then
        table.remove(self, i)
        return true
    end

    return false
end

-- endregion

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
