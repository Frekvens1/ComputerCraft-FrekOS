-- region { private }

local api = {}

-- endregion


-- region { string overwrites }


-- endregion


-- region { table overwrites }

function table.compare(self, value)
    if not self or not value then return false end
    if #self ~= #value then return false end
    for i = 1, #self do
        if self[i] ~= value[i] then
            return false
        end
    end
    return true
end

function table.includes(table, item)
    for _, value in ipairs(table) do
        if value == item then
            return true
        end
    end
    return false
end

-- endregion

function api.clear()
    term.clear()
    term.setCursorPos(1, 1)
end



local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
