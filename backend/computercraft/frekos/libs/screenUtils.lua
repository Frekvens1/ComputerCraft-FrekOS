local api = {}

function api.clear()
    term.clear()
    term.setCursorPos(1,1)
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


function beforeLoad()

end

function afterLoad()

end

return api, beforeLoad, afterLoad
