local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

function main()
    print("FrekOS is booting up...")
     printLine()

    shell.setPath(shell.path() .. ":/frekos/apps:/apps")
    loadLibraries("/frekos/libs")
    os.sleep(2)
end

function loadLibraries(library_path)
    local libs = {
        before = {},
        after = {}
    }
    print()
    print("=== Loading libraries ===")
    printLine()

    for _, file in ipairs(fs.list(library_path)) do
        local file_path = fs.combine(library_path, file)

        if not fs.isDir(file_path) and file:match("%.lua$") then
            local name = file:gsub("%.lua$", "")

            print("- Loading '" .. name .. "'...")

            -- Load the file as a function
            local fn = loadfile(file_path)
            local api, beforeLoad, afterLoad = fn()

            -- Expose API globally
            _G[name] = api

            if beforeLoad then
                libs.before[name] = beforeLoad
            end
            if afterLoad then
                libs.after[name] = afterLoad
            end
        end
    end

    print()
    print("=== Running beforeLoad hooks ===")
    printLine()

    for name, hook in pairs(libs.before) do
        print(name)
        printLine(#name)
        hook()
        print()
    end

    print()
    print("=== Running afterLoad hooks ===")
    printLine()

    for name, hook in pairs(libs.after) do
        print(name)
        printLine(#name)
        hook()
        print()
    end

    print()
    print(":: Libraries fully loaded")
end

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

function printLine(count)
    local termSize = term.getSize()
    if count == nil then
        count = termSize
    end

    if count > termSize then
        count = termSize
    end

    print(string.rep("-", count))
end

clear()
main()

os.pullEvent = pullEvent
clear()
