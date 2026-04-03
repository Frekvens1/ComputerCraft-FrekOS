-- region { private }

local api = {}

-- endregion

function table.compare(a, b)
    if not a or not b then
        return false
    end

    if #a ~= #b then
        return false
    end

    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end

    return true
end

function table.combine(a, b)
    local result = {}
    for i = 1, #a do
        result[#result + 1] = a[i]
    end

    for i = 1, #b do
        result[#result + 1] = b[i]
    end

    return result
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

function table.invert(self)
   local inverted_table = {}
   for key, value in pairs(self) do
     inverted_table[value] = key
   end

   return inverted_table
end


local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
