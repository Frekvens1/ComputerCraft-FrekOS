local shell_args = { ... }

local function shell()
    local self = {}
    local commands, folder_commands, current_path, is_running

    local function registerFolder(tbl, folder_path)
        for _, file in ipairs(fs.list(folder_path)) do
            local file_path = fs.combine(folder_path, file)

            if not fs.isDir(file_path) and file:match("%.lua$") then
                local name = file:gsub("%.lua$", "")
                local fn = function(args)
                    self.is_running_app = true
                    os.run(_G, file_path, table.unpack(args))
                    self.is_running_app = false
                end

                tbl[file] = fn
                tbl[name] = fn

            end

        end
    end

    local function init()
        if current_path == nil then
            current_path = "/"
        end

        commands = {}
        folder_commands = {}
        is_running = true

        term.setCursorBlink(true)
        os.run("/frekos/apps/welcome_screen.lua")
        ---------------------------------------------------------
        -- Built‑in commands
        ---------------------------------------------------------
        self.register("echo", function(args)
            print(table.concat(args, " "))
        end)

        self.register("cd", function(args)
            local path = args[1] or "/"

            if not string.find(path, "^/") then
                path = fs.combine(current_path, path)
            end

            path = fs.normalize(path)

            if fs.isDir(path) then
                self.setDir(path)
            else
                print("No such directory:", path)
            end
        end)

        self.register("ls", function(args)
            local path = args[1] and fs.combine(current_path, args[1]) or current_path
            if not fs.exists(path) or not fs.isDir(path) then
                print("No such directory:", path)
                return
            end

            local items = fs.list(path)

            local dirs, files = {}, {}
            for _, item in ipairs(items) do
                local full = fs.combine(path, item)
                if fs.isDir(full) then
                    table.insert(dirs, item)
                else
                    table.insert(files, item)
                end
            end

            table.sort(dirs)
            table.sort(files)

            local longest = 0
            for _, item in ipairs(items) do
                if #item > longest then
                    longest = #item
                end
            end

            local w = term.getSize()
            local colWidth = longest + 2
            local cols = math.max(1, math.floor(w / colWidth))

            local function printGroup(list, color)
                for i, item in ipairs(list) do
                    term.setTextColor(color)
                    term.write(item)
                    term.write(string.rep(" ", colWidth - #item))

                    if i % cols == 0 then
                        print()
                    end
                end

                if #list % cols ~= 0 then
                    print()
                end
            end

            if #dirs > 0 then
                printGroup(dirs, colors.green)
            end

            if #files > 0 then
                printGroup(files, colors.white)
            end

            term.setTextColor(colors.white)
        end)

        self.register("exit", function(args)
            return "exit"
        end)

        registerFolder(folder_commands, current_path)
        registerFolder(commands, "/frekos/apps")
        registerFolder(commands, "/apps/turtle")
        registerFolder(commands, "/apps")

        self.register("lua", function()
            term.setTextColor(colors.yellow)
            print("Interactive Lua prompt.")
            print("Type 'exit' to leave.")
            term.setTextColor(colors.white)

            while is_running do
                write("lua> ")
                local line = read()

                if not line or line == "exit" or line == "exit()" then
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

    local function start()
        init()

        frekos.setShell(self)
        if fs.exists(shell_args[1]) then
            self.is_running_app = true
            os.run(_G, shell_args[1], table.unpack(shell_args, 2, #shell_args))
            self.is_running_app = false
            os.run("/frekos/apps/welcome_screen.lua")
        end

        while is_running do
            term.setTextColor(colors.yellow)
            write(current_path .. "> ")
            term.setTextColor(colors.white)

            local line = read()

            local parts = {}
            for part in string.gmatch(line, "%S+") do
                table.insert(parts, part)
            end

            local cmd = parts[1]
            table.remove(parts, 1)

            if cmd then
                local fn = commands[cmd] or folder_commands[cmd]
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

    function self.register(name, fn)
        commands[name] = fn
    end

    function self.exit()
        is_running = false
    end

    function self.setDir(path)
        current_path = path

        folder_commands = {}
        registerFolder(folder_commands, current_path)
    end

    function self.dir()
        return current_path
    end

    return self, start
end

local sh, start = shell()
_G.shell = sh

start()
