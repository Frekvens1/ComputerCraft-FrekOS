local shell = {}

function shell.new()
    term.setCursorBlink(true)
    term.setTextColor(colors.orange)
    term.setBackgroundColor(colors.black)

    term.clear()
    term.setCursorPos(1, 1)

    print("FrekOS v0.1")
    local width, height = term.getSize()
    term.setTextColor(colors.lightGray)
    print(string.rep("-", width))
    term.setTextColor(1)

    local cwd = "/"

    local commands = {}

    ---------------------------------------------------------
    -- Register a command
    ---------------------------------------------------------
    local function register(name, fn)
        commands[name] = fn
    end

    ---------------------------------------------------------
    -- Built‑in commands
    ---------------------------------------------------------
    register("echo", function(args)
        print(table.concat(args, " "))
    end)

    register("cd", function(args)
        local path = args[1] or "/"
        if fs.isDir(path) then
            cwd = path
        else
            print("No such directory:", path)
        end
    end)

    register("ls", function(args)
        local list = fs.list(cwd)
        for _, item in ipairs(list) do
            print(item)
        end
    end)

    register("exit", function()
        print("Exiting shell")
        return "exit"
    end)

    register("clean_install", function()
        os.run("/frekos/apps/clean_install.lua")
    end)

    register("update", function()
        os.run("/frekos/apps/update.lua")
    end)

    register("lua", function()
        print("Entering Lua REPL. Type 'exit' to leave.")

        while true do
            write("lua> ")
            local line = read()

            if not line or line == "exit" then
                print("Leaving Lua REPL.")
                return
            end

            -- Try "return <expr>" first
            local fn = load("return " .. line, "repl", "t", _G)
            if not fn then
                -- Fall back to statement mode
                fn = load(line, "repl", "t", _G)
            end

            if fn then
                local ok, result = pcall(fn)
                if ok then
                    print(result)
                else
                    print("Error:", result)
                end
            else
                print("Syntax error")
            end
        end
    end)

    return function()
        ---------------------------------------------------------
        -- Main shell loop
        ---------------------------------------------------------
        while true do
            term.setTextColor(colors.yellow) -- yellow
            write(cwd .. "> ")
            term.setTextColor(colors.white) -- white

            local line = read()

            local parts = {}
            for part in string.gmatch(line, "%S+") do
                table.insert(parts, part)
            end

            local cmd = parts[1]
            table.remove(parts, 1)

            if cmd then
                local fn = commands[cmd]
                if fn then
                    local result = fn(parts)
                    if result == "exit" then
                        return
                    end
                else
                    print("Unknown command:", cmd)
                end
            end
        end
    end
end

return shell
