local completion = require "cc.shell.completion"
local error_loading_libraries = false
local errors = {}

function main()
    print("FrekOS is booting up...")
    printLine()

    shell.setPath(shell.path() .. ":/frekos/apps:/apps:/apps/turtle")
    shell.setCompletionFunction("frekos/apps/cat.lua", function(shell, index, text, previous)
        if index == 1 then
            return completion.file(shell, text)
        end
    end)

    loadLibraries("/frekos/libs")
    FrekOS.events.inject()
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

        if fs.isDir(file_path) or not file:match("%.lua$") then
            goto continue
        end

        local name = file:gsub("%.lua$", "")
        print("- Loading '" .. name .. "'...")

        local env = {}
        env._ENV = env
        setmetatable(env, { __index = _ENV })
        env.shell = shell

        local okLoad, fn = pcall(loadfile, file_path)
        if not okLoad then
            error_loading_libraries = true
            goto continue
        end

        setfenv(fn, env)

        local okRun, api, beforeLoad, afterLoad = pcall(fn)
        if not okRun then
            error_loading_libraries = true
            goto continue

            print("= Press a key to continue =")
            os.pullEvent("key")
        end

        if api then
            _G[name] = api
        end

        if beforeLoad then
            libs.before[name] = beforeLoad
        end

        if afterLoad then
            libs.after[name] = afterLoad
        end

        :: continue ::
    end

    print()
    print("=== Running beforeLoad hooks ===")
    printLine()

    for name, hook in pairs(libs.before) do
        print(name)
        printLine(#name)
        local ok, err = pcall(hook)
        if not ok then
            error_loading_libraries = true
            print("Crashed:")
            print(err)

            print("= Press a key to continue =")
            os.pullEvent("key")
        end
        print()
    end

    print()
    print("=== Running afterLoad hooks ===")
    printLine()

    for name, hook in pairs(libs.after) do
        print(name)
        printLine(#name)
        local ok, err = pcall(hook)
        if not ok then
            error_loading_libraries = true
            print("Crashed:")
            print(err)

            print("= Press a key to continue =")
            os.pullEvent("key")
        end
        print()
    end

    print()
    if not error_loading_libraries then
        print(":: Libraries fully loaded")
    else
        print("Failed loading libraries")
        print()
        print("= Press a key to continue =")
        os.pullEvent("key")
    end
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
