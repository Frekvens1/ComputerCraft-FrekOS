function string.includes(self, text)
    return self:find(text) ~= nil
end

function string.contains(self, text)
    return string.includes(self, text)
end
