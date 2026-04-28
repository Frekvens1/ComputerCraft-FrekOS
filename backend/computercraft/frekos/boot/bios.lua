local function BIOS()
    local self = {
        colors = {
            white = 1,
            red = 16384
        }
    }

    function self.init()
        term.setCursorBlink(false)

        _G._HOST = _G._HOST .. " (FrekOS)"
        local fn, load_error = self.loadfile("/frekos/kernel/init.lua")
        if not fn then
            term.clear()
            term.setCursorPos(1, 1)
            term.setCursorBlink(false)

            self.printError("Failed to load FrekOS kernel:")
            self.printError(load_error)
            self.print()
            self.print("Press any key to shutdown.")
            coroutine.yield("key")
            return
        end

        local ok, run_error = pcall(fn)
        if not ok then
            term.setBackgroundColor(self.colors.red)
            term.clear()
            term.setCursorPos(1, 1)
            term.setCursorBlink(false)

            self.print("FrekOS Kernel Panic")
            self.print(run_error)
            self.print()
            self.print("Press any key to shutdown.")
            coroutine.yield("key")
            return
        end
    end

    function self.loadfile(path)
        local file = fs.open(path, "r")
        if not file then
            return nil, "File not found"
        end
        local data = file.readAll()
        file.close()
        return load(data, "@" .. path, "t", _G)
    end

    function self.printError(text)
        self.print(text, self.colors.red)
    end

    function self.print(text, color)
        local w, h = term.getSize()
        local x, y = term.getCursorPos()

        if text then
            if color == nil then
                color = self.colors.white
            end

            term.setTextColor(color)

            for i = 1, #text do
                local char = text:sub(i, i)

                if x > w then
                    x = 1
                    y = y + 1
                    if y > h then
                        term.scroll(1)
                        y = h
                    end
                    term.setCursorPos(x, y)
                end

                term.write(char)
                x = x + 1
            end

        end

        y = y + 1
        if y > h then
            term.scroll(1)
            y = h
        end
        term.setCursorPos(1, y)
    end

    return self
end

BIOS().init()
os.shutdown()
coroutine.yield()
