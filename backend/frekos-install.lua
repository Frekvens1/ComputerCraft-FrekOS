term.clear()
term.setCursorPos(1, 1)

printError("WARNING! DO NOT UPDATE!")
print("FrekOS is currently being rewritten.")
print()
print("Press enter to update, any other key to reboot.")

local event, char = coroutine.yield("key")
if char ~= keys.enter then
    os.reboot()
end

local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local args = { ... }
local device_uuid = args[1]

if not device_uuid then
    print("Error: No UUID specified.")
    print("Usage: wget run <url> <uuid>")
    coroutine.yield("key")
    shell.exit()
end

app_config = {
    has_ssl = true,
    hostname = "frekos.cc",
    api_path = "/api",
    scripts_path = "/api/computercraft",
    update_url = "https://update.frekos.cc",
}

local downloads = {
    "/startup.lua",

    -- region { System files - Boot }

    "/frekos/boot/bios.lua",
    "/frekos/boot/unbios.lua",

    -- endregion

    -- region { System files - Applications }

    "/frekos/apps/tps.lua",
    "/frekos/apps/shell.lua",
    "/frekos/apps/update.lua",
    "/frekos/apps/clean_install.lua",
    "/frekos/apps/wipe_device.lua",

    -- endregion

    -- region { System files - Kernel }

    "/frekos/kernel/init.lua",

    "/frekos/kernel/api/frekos.lua",
    "/frekos/kernel/api/backend.lua",
    "/frekos/kernel/api/screen.lua",
    "/frekos/kernel/api/fs.lua",
    "/frekos/kernel/api/http.lua",
    "/frekos/kernel/api/io.lua",
    "/frekos/kernel/api/os.lua",
    "/frekos/kernel/api/peripheral.lua",
    "/frekos/kernel/api/redstone.lua",
    "/frekos/kernel/api/textutils.lua",

    "/frekos/kernel/core/events.lua",
    "/frekos/kernel/core/loader.lua",
    "/frekos/kernel/core/process.lua",
    "/frekos/kernel/core/scheduler.lua",
    "/frekos/kernel/core/syscalls.lua",
    "/frekos/kernel/core/utils.lua",

    "/frekos/kernel/drivers/disk.lua",
    "/frekos/kernel/drivers/gpu.lua",
    "/frekos/kernel/drivers/modem.lua",
    "/frekos/kernel/drivers/monitor.lua",

    "/frekos/kernel/tasks/shell.lua",
    "/frekos/kernel/tasks/backend.lua",
    "/frekos/kernel/tasks/teleport.lua",

    -- endregion

    -- region { System files - Libraries }

    -- endregion
}

local protocol = "http"
if app_config.has_ssl then
    protocol = protocol .. "s"
end

local server_hostname = protocol .. "://" .. app_config.hostname .. app_config.scripts_path
local device_config_url = protocol .. "://" .. app_config.hostname .. "/api/device/" .. device_uuid

function main()
    clear()

    print("Installing FrekOS v0.1")
    print(hr())
    print()

    local device_config = textutils.unserializeJSON(get(device_config_url))
    os.setComputerLabel(device_config.name)

    local all_downloads = downloads
    bulkDownload(all_downloads)

    print()
    print(hr())
    print()

    local settings = {
        device_uuid = device_uuid,
        has_ssl = app_config.has_ssl,
        hostname = app_config.hostname,
        api_path = app_config.api_path,
        update_url = app_config.update_url,
        send_events = false,
    }

    saveConfig("/frekos/config/settings.conf", settings)
    saveConfig("/frekos/config/device.conf", device_config)

    print("Install complete!")
    print()
    print()

    reboot()
end

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

function hr()
    local w = term.getSize()
    return string.rep("-", w)
end

function saveConfig(path, variable)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(variable))
    file.close()
end

function get(url)
    local request = http.request or http.native.request

    local ok, err = request(url)
    if not ok then
        return nil, err
    end

    while true do
        local event, event_url, handle = coroutine.yield()

        if event == "http_success" and event_url == url then
            local content = handle.readAll()
            handle.close()
            return content, nil
        end

        if event == "http_failure" and event_url == url then
            return nil, handle
        end
    end
end

function bulkDownload(filepaths)
    print("Downloading files...")
    print(hr())
    for _, filepath in ipairs(filepaths) do
        download(filepath)
    end
end

function download(filepath, save_path)
    if save_path == nil then
        save_path = filepath
    end

    print("- " .. filepath)
    local fileContent = get(server_hostname .. filepath)

    if (fileContent == nil) then
        print("  - Download failed!\n")
        return false
    end

    if (fs.exists(save_path)) then
        fs.delete(save_path)
    end

    ensureDir(save_path)

    local file = fs.open(save_path, "w")
    file.write(fileContent)
    file.close()

    return true
end

function ensureDir(path)
    local parent = fs.getDir(path)
    if parent ~= "" and not fs.exists(parent) then
        fs.makeDir(parent)
    end
end

function reboot()
    write("Rebooting in 3.. ")
    os.sleep(1)

    write("2.. ")
    os.sleep(1)

    write("1.. ")
    os.sleep(1)

    os.reboot()
end

function table.combine(a, b)
    local result = {}
    for i = 1, #a do
        result[#result + 1] = a[i]
    end

    for i = 1, #b do
        result[#result + 1] = b[i]
    end

    return result
end

main()

os.pullEvent = pullEvent
