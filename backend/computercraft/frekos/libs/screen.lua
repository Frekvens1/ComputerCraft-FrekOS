-- region { private }

local api = {}

-- endregion

function api.clear()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    term.clear()
    term.setCursorPos(1, 1)
end

function api.saveColors(savedColors)
    if savedColors == nil then
        savedColors = {}
    end

    api.savedColors = {
        textColor = term.getTextColor(),
        backgroundColor = term.getBackgroundColor(),
    }

    return api.savedColors
end

function api.restoreColors(savedColors)
    if savedColors == nil then
        savedColors = api.savedColors
    end

    term.setTextColor(savedColors.textColor)
    term.setBackgroundColor(savedColors.backgroundColor)
end

function api.printLine(count)
    local termSize = term.getSize()
    if count == nil then
        count = termSize
    end

    if count > termSize then
        count = termSize
    end

    print(string.rep("-", count))
end

local function beforeLoad()
    api.saveColors()
end

local function afterLoad()

end

return api, beforeLoad, afterLoad
