local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

app_config = {
    has_ssl = true,
    hostname = "frekos.cc",
    api_path = "/api",
    scripts_path = "/api/computercraft",
    update_url = "https://update.frekos.cc",
}

local downloads = {
    "/startup.lua",
    "/frekos/startup.lua",

    -- region { System files - Applications }

    "/frekos/apps/cat.lua",
    "/frekos/apps/tps.lua",
    "/frekos/apps/kiosk.lua",
    "/frekos/apps/update.lua",
    "/frekos/apps/lockscreen.lua",
    "/frekos/apps/clean_install.lua",
    "/frekos/apps/welcome_screen.lua",

    -- endregion

    -- region { System files - Libraries }

    "/frekos/libs/gui.lua",
    "/frekos/libs/utils.lua",
    "/frekos/libs/FrekOS.lua",
    "/frekos/libs/screen.lua",
    "/frekos/libs/fileUtils.lua",
    "/frekos/libs/audioUtils.lua",
    "/frekos/libs/tableUtils.lua",
    "/frekos/libs/stringUtils.lua",
    "/frekos/libs/backendUtils.lua",
    "/frekos/libs/peripheralsLib.lua",

    -- endregion

    -- region { System files - Libraries - APIs}

    "/frekos/libs/api/device.lua",
    "/frekos/libs/api/music.lua",

    -- endregion

    -- region { System files - Libraries - GUIs}

    "/frekos/libs/gui/render.lua",
    "/frekos/libs/gui/createApp.lua",

    "/frekos/libs/gui/components/super.lua",
    "/frekos/libs/gui/components/label.lua",
    "/frekos/libs/gui/components/input.lua",
    "/frekos/libs/gui/components/button.lua",

    -- endregion

    -- region { Applications }

    "/apps/music.lua",
    "/apps/gui_test.lua",
    "/apps/teleport.lua",
    "/apps/teleport_requester.lua",

    -- endregion

    -- region { Restaurant }

    "/apps/restaurant/kitchen_terminal.lua",
    "/apps/restaurant/order_terminal.lua",

    -- endregion
}

local downloads_turtle = {
    "/frekos/apps/turtle.lua",
    "/frekos/libs/turtleUtils.lua",

    "/apps/turtle/build_roof.lua",
    "/apps/turtle/lava_refill.lua",
    "/apps/turtle/chunk_miner.lua",
    "/apps/turtle/tunnel_miner.lua",
    "/apps/turtle/quartz_miner.lua",
    "/apps/turtle/quartz_replacer.lua",
}

local downloads_storage = {
    "/frekos/libs/api/storage.lua",

    "/frekos/libs/storageUtils.lua",

    "/apps/storage.lua",
}

local protocol = "http"
if app_config.has_ssl then
    protocol = protocol .. "s"
end

local args = {...}
local device_uuid = args[1]

if not device_uuid then
    print("Error: No UUID specified.")
    print("Usage: wget run <url> <uuid>")
    return
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
    if turtle then
        all_downloads = table.combine(all_downloads, downloads_turtle)
    end

    if device_config.type == "storage_module" or turtle then
        all_downloads = table.combine(all_downloads, downloads_storage)
    end

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

    saveConfig("/frekos/settings.conf", settings)
    saveConfig("/frekos/device.conf", device_config)

    print("Install complete!")
    print()
    print()

    reboot()
end

function clear()
    term.clear()
    term.setCursorPos(1,1)
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
    local ok, err = http.checkURL(url)
    if not ok then
        return nil
    end

    local response = http.get(url, nil, true)
    if not response then
        return nil
    end

    local text = response.readAll()
    response.close()

    return text
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
