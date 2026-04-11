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

_G.read = function()
    local buffer = {}
    local cursor = 0

    local function redraw()
        local current_x, current_y = term.getCursorPos()
        term.setCursorPos(current_x, current_y)
        write(table.concat(buffer))
        -- Clear any leftover characters
        write(" ")
        term.setCursorPos(current_x - (#buffer - cursor), current_y)
    end

    while true do
        local event, p1 = coroutine.yield()

        if event == "char" then
            -- Insert character at cursor
            table.insert(buffer, cursor + 1, p1)
            cursor = cursor + 1
            redraw()

        elseif event == "key" then
            local key = p1

            -- ENTER
            if key == keys.enter then
                print()
                return table.concat(buffer)

            -- BACKSPACE
            elseif key == keys.backspace then
                if cursor > 0 then
                    table.remove(buffer, cursor)
                    cursor = cursor - 1
                    redraw()
                end

            -- DELETE
            elseif key == keys.delete then
                if cursor < #buffer then
                    table.remove(buffer, cursor + 1)
                    redraw()
                end

            -- LEFT ARROW
            elseif key == keys.left then
                if cursor > 0 then
                    cursor = cursor - 1
                    local x, y = term.getCursorPos()
                    term.setCursorPos(x - 1, y)
                end

            -- RIGHT ARROW
            elseif key == keys.right then
                if cursor < #buffer then
                    cursor = cursor + 1
                    local x, y = term.getCursorPos()
                    term.setCursorPos(x + 1, y)
                end

            -- HOME
            elseif key == keys.home then
                local x, y = term.getCursorPos()
                term.setCursorPos(x - cursor, y)
                cursor = 0

            -- END
            elseif key == keys["end"] then
                local x, y = term.getCursorPos()
                term.setCursorPos(x + (#buffer - cursor), y)
                cursor = #buffer
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
