-- region { private }

local api = {
    native = _G.io,
}

-- endregion

-- region { native functions }

-- endregion

_G.print = function(...)
    local args = table.pack(...)
    local text = ""

    -- Build the full string with spaces between arguments
    for i = 1, args.n do
        text = text .. tostring(args[i])
        if i < args.n then
            text = text .. " "
        end
    end

    local w, h = term.getSize()
    local x, y = term.getCursorPos()

    -- Write each character manually with wrapping
    for i = 1, #text do
        local ch = text:sub(i, i)

        -- If at end of line, wrap
        if x > w then
            x = 1
            y = y + 1

            -- Scroll if needed
            if y > h then
                term.scroll(1)
                y = h
            end

            term.setCursorPos(x, y)
        end

        term.write(ch)
        x = x + 1
    end

    -- After printing the line, move to next line
    x = 1
    y = y + 1

    if y > h then
        term.scroll(1)
        y = h
    end

    term.setCursorPos(x, y)
end

_G.printError = function(...)
    local color = term.getTextColor()
    term.setTextColor(16384) -- red
    print(...)
    term.setTextColor(color)
end

_G.error = function(...)
    printError(...)
end

_G.write = function(str)
    term.write(str)
end

_G.read = function(maskChar)
    local buffer = {}
    local cursor = 0  -- logical cursor index

    -- Capture starting cursor position
    local originX, originY = term.getCursorPos()
    local w = term.getSize()

    -- Maximum width of the editable area
    local maxVisible = w - originX + 1

    local function redraw()
        -- Determine visible window
        local start = 1

        if cursor + 1 > start + maxVisible - 1 then
            start = cursor + 1 - maxVisible + 1
        end

        if cursor < start - 1 then
            start = cursor
        end

        -- Build visible text
        local text = table.concat(buffer)

        if maskChar then
            text = text:gsub(".", maskChar)
        end

        local visible = text:sub(start, start + maxVisible - 1)

        -- Draw line starting at origin
        term.setCursorPos(originX, originY)
        term.write(visible)

        -- Clear leftover characters
        term.write(string.rep(" ", maxVisible - #visible))

        -- Move cursor to correct terminal position
        local cursorX = originX + (cursor - (start - 1))
        term.setCursorPos(cursorX, originY)
    end

    redraw()

    while true do
        local event, p1 = coroutine.yield()

        if event == "char" then
            table.insert(buffer, cursor + 1, p1)
            cursor = cursor + 1
            redraw()

        elseif event == "key" then
            local key = p1

            if key == keys.enter then
                print()
                return table.concat(buffer)

            elseif key == keys.backspace then
                if cursor > 0 then
                    table.remove(buffer, cursor)
                    cursor = cursor - 1
                    redraw()
                end

            elseif key == keys.delete then
                if cursor < #buffer then
                    table.remove(buffer, cursor + 1)
                    redraw()
                end

            elseif key == keys.left then
                if cursor > 0 then
                    cursor = cursor - 1
                    redraw()
                end

            elseif key == keys.right then
                if cursor < #buffer then
                    cursor = cursor + 1
                    redraw()
                end

            elseif key == keys.home then
                cursor = 0
                redraw()

            elseif key == keys["end"] then
                cursor = #buffer
                redraw()
            end
        end
    end
end

for key, value in pairs(_G.keys) do
    _G.keys[value] = key
end

for key, value in pairs(_G.colors) do
    _G.colors[value] = key
end

_G.colours = _G.colors

return api
