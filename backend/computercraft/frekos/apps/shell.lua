local function shell()
    local self = {}

    local function init()
        self.cwd = "/"
        self.commands = {}

        term.setCursorBlink(true)
        term.setTextColor(colors.orange)
        term.setBackgroundColor(colors.black)

        term.clear()
        term.setCursorPos(1, 1)

        print("FrekOS v0.1")
        term.setTextColor(colors.lightGray)
        local width, height = term.getSize()
        print(string.rep("\131", width))
        term.setTextColor(colors.white)

        ---------------------------------------------------------
        -- Built‑in commands
        ---------------------------------------------------------
        self.register("echo", function(args)
            print(table.concat(args, " "))
        end)

        self.register("cd", function(args)
            local path = args[1] or "/"
            if fs.isDir(path) then
                self.cwd = path
            else
                print("No such directory:", path)
            end
        end)

        self.register("ls", function(args)
            local list = fs.list(self.cwd)
            for _, item in ipairs(list) do
                print(item)
            end
        end)

        self.register("exit", function(args)
            print("Exiting shell")
            return "exit"
        end)

        self.registerFolder("/frekos/apps")
        self.registerFolder("/apps/turtle")
        self.registerFolder("/apps")

        self.register("lua", function()
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
    end

    function self.register(name, fn)
        self.commands[name] = fn
    end

    function self.registerFolder(folder_path)
        for _, file in ipairs(fs.list(folder_path)) do
            local file_path = fs.combine(folder_path, file)

            if not fs.isDir(file_path) and file:match("%.lua$") then
                local name = file:gsub("%.lua$", "")

                self.register(file, function(args)
                    os.run(file_path, table.unpack(args))
                end)

                self.register(name, function(args)
                    os.run(file_path, table.unpack(args))
                end)
            end

        end
    end

    function self.loop()
        init()

        while true do
            term.setTextColor(colors.yellow)
            write(self.cwd .. "> ")
            term.setTextColor(colors.white)

            local line = read()

            local parts = {}
            for part in string.gmatch(line, "%S+") do
                table.insert(parts, part)
            end

            local cmd = parts[1]
            table.remove(parts, 1)

            if cmd then
                local fn = self.commands[cmd]
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

    return self
end

return shell().loop
