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
    "/frekos/apps/update.lua",
    "/frekos/apps/lockscreen.lua",
    "/frekos/apps/clean_install.lua",
    "/frekos/apps/welcome_screen.lua",

    -- endregion

    -- region { System files - Libraries }

    "/frekos/libs/FrekOS.lua",
    "/frekos/libs/fileUtils.lua",
    "/frekos/libs/deviceApi.lua",
    "/frekos/libs/turtleUtils.lua",
    "/frekos/libs/stringUtils.lua",
    "/frekos/libs/backendUtils.lua",
    "/frekos/libs/screenUtils.lua",
    "/frekos/libs/peripheralsLib.lua",

    -- endregion

    -- region { Applications }

    "/apps/storage.lua",
    "/apps/teleport.lua",
    "/apps/teleport_requester.lua",

    -- endregion
}

local downloads_turtle = {
    -- region { Applications - Turtle }

    "/apps/turtle/build_roof.lua",
    "/apps/turtle/lava_refill.lua",
    "/apps/turtle/chunk_miner.lua",
    "/apps/turtle/tunnel_miner.lua",
    "/apps/turtle/quartz_miner.lua",
    "/apps/turtle/quartz_replacer.lua",

    -- endregion
}

local protocol = "http"
if app_config.has_ssl then
    protocol = protocol .. "s"
end

local serverHostname = protocol .. "://" .. app_config.hostname .. app_config.scripts_path

local args = {...}
local device_uuid = args[1]

if not device_uuid then
    print("Error: No UUID specified.")
    print("Usage: wget run <url> <uuid>")
    return
end

function main()
    clear()

    print("Installing FrekOS v0.1")
    print(hr())
    print()

    local all_downloads = downloads
    if turtle then
        all_downloads = table.combine(all_downloads, downloads_turtle)
    end

    bulkDownload(all_downloads)

    print()
    print(hr())
    print()

    local config = {
        device_uuid = device_uuid,
        has_ssl = app_config.has_ssl,
        hostname = app_config.hostname,
        api_path = app_config.api_path,
        update_url = app_config.update_url,
        send_events = false,
    }

    saveConfig("/frekos/settings.conf", config)

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
    local fileContent = get(serverHostname .. filepath)

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
