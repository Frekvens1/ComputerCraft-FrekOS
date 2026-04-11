-- TLCO based on OpusOS
-- https://github.com/kepler155c/opus/blob/develop-1.8/sys/boot/tlco.lua

local run = os.run
local shutdown = os.shutdown

local args = {...}

local function bootFrekOS(...)
    local fn, load_error = loadfile("/frekos/boot/kernel.lua")
    if not fn then
        printError("Failed to load FrekOS kernel:")
        printError(load_error)
		print()
        print("Press any key to shutdown.")
        coroutine.yield("key")
        -- os.shutdown()
		return nil
    end

	local ok, run_error = pcall(bootFrekOS, ...)
	if not ok then
		term.setBackgroundColor(colors.red)
		term.clear()
		term.setCursorPos(1, 1)

		print("FrekOS Kernel Panic")
		print(run_error)
		print()
		print("Press any key to shutdown.")
		coroutine.yield("key")
		-- os.shutdown()
	end
end

os.run = function()
	os.run = run
end

os.shutdown = function()
	os.shutdown = shutdown
	bootFrekOS(args)
end

-- term.clear()
-- term.setCursorPos(1, 1)

-- shell.exit()
-- os.shutdown()
