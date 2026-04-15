local function KERNEL()
    local self = {
        debug = false
    }

    function self.init()
        local api, apiErrors = self.loadFolder("/frekos/kernel/api")
        local core, coreErrors = self.loadFolder("/frekos/kernel/core")
        local drivers, driverErrors = self.loadFolder("/frekos/kernel/drivers")
        local tasks, taskErrors = self.loadFolder("/frekos/kernel/tasks")

        for name, fn in pairs(api) do
            _G[name] = fn
        end

        for name, fn in pairs(api) do
            if fn.init then
                fn.init()
            end
        end

        if self.debug then
            print("Displaying all tasks:")
            for name, fn in pairs(tasks) do
                print(name)
                print(fn)
            end

            print("Displaying all tasks errors:")
            for name, data in pairs(taskErrors) do
                print(name)
                print(data.type)
                print(data.message)
                print()
            end

            coroutine.yield("key")
        end

        for name, fn in pairs(tasks) do
            frekos.spawn(fn, name)
        end

        frekos.spawn(function()
            dofileSandbox("/frekos/apps/shell.lua", "shell")
            term.setTextColor(colors.yellow)
            print("Nap time!")
            os.sleep(1)
            os.shutdown()
        end)

        core.events.init()
        
        while true do
            core.events.handleEvent()
        end
    end

    function self.loadFolder(folder_path)
        local results = {}
        local errors = {}

        for _, file in ipairs(fs.list(folder_path)) do
            local file_path = fs.combine(folder_path, file)
            if fs.isDir(file_path) or not file:match("%.lua$") then
                goto continue
            end

            local name = file:gsub("%.lua$", "")

            local file_handle = fs.open(file_path, "r")
            local data = file_handle.readAll()
            file_handle.close()

            local fn, load_error = load(data, "@" .. file_path, "t", _G)
            if not fn then
                errors[name] = {
                    type = "LOAD",
                    message = load_error,
                }
                goto continue
            end

            local result = { pcall(fn) }
            if not result[1] then
                errors[name] = {
                    type = "RUN",
                    message = result[2],
                }
                goto continue
            end

            results[name] = table.unpack(result, 2)

            :: continue ::
        end

        return results, errors
    end

    return self
end

KERNEL().init()
