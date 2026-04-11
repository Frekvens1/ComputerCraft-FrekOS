local completion = require "cc.shell.completion"
local error_loading_libraries = false
local logs = {}

local function printLog(text)
    if text == nil then
        text = ""
    end

    table.insert(logs, text)
    print(text)
end

local function main()
    printLog("FrekOS is booting up...")
    printLine()

    shell.setPath(shell.path() .. ":/frekos/apps:/apps:/apps/turtle")

    setAutoComplete("frekos/apps/audio.lua")
    setAutoComplete("frekos/apps/cat.lua")

    loadLibraries("/frekos/libs")
    FrekOS.events.inject()
end

function setAutoComplete(file_path)
    shell.setCompletionFunction(file_path, function(shell, index, text, previous)
        if index == 1 then
            return completion.file(shell, text)
        end
    end)
end

function loadLibraries(library_path)
    local libs = {
        before = {},
        after = {}
    }
    printLog()
    printLog("=== Loading libraries ===")
    printLine()

    for _, file in ipairs(fs.list(library_path)) do
        local file_path = fs.combine(library_path, file)

        if fs.isDir(file_path) or not file:match("%.lua$") then
            goto continue
        end

        local name = file:gsub("%.lua$", "")
        printLog("- Loading '" .. name .. "'...")

        local env = {}
        env._ENV = env
        setmetatable(env, { __index = _ENV })
        env.shell = shell

        local okLoad, fn = pcall(loadfile, file_path)
        if not okLoad then
            error_loading_libraries = true
            printLog("Crashed while reading library:")
            printLog(fn)
            goto continue
        end

        setfenv(fn, env)

        local okRun, api, beforeLoad, afterLoad = pcall(fn)
        if not okRun then
            error_loading_libraries = true
            printLog("Crashed while loading library:")
            printLog(api)
            goto continue
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

    printLog()
    printLog("=== Running beforeLoad hooks ===")
    printLine()

    local env = {}
    env._ENV = env
    setmetatable(env, { __index = _ENV })
    env.shell = shell

    for name, hook in pairs(libs.before) do
        printLog(name)
        printLine(#name)
        setfenv(hook, env)
        local ok, err = pcall(hook)
        if not ok then
            error_loading_libraries = true
            printLog("Crashed:")
            printLog(err)
        end
        printLog()
    end

    env._ENV = env
    setmetatable(env, { __index = _ENV })
    env.shell = shell

    printLog()
    printLog("=== Running afterLoad hooks ===")
    printLine()

    for name, hook in pairs(libs.after) do
        printLog(name)
        printLine(#name)
        setfenv(hook, env)
        local ok, err = pcall(hook)
        if not ok then
            error_loading_libraries = true
            printLog("Crashed:")
            printLog(err)
        end
        printLog()
    end

    printLog()
    if not error_loading_libraries then
        printLog(":: Libraries fully loaded")
    else
        printLog("Failed loading libraries")
        printLog()
        printLog("= Press a key to continue =")

        backendUtils.send({
            storage_uuid = name,
            inventory = inventory
        })

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

    printLog(string.rep("-", count))
end

clear()
main()
