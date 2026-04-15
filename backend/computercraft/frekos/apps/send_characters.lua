local chars = {}
for index = 0, 255, 1 do
    chars["" .. index] = string.char(index)
end

backend.send(chars)
