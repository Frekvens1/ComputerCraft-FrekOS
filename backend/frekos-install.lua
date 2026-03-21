local serverHostname = "https://frekos.cc/api/computercraft/"

function main()
    clear()

    print("Installing FrekOS v0.1")
    print(hr())
    print()

    bulkDownload({
        "startup.lua",

        -- region { System files - Applications }

        "frekos/apps/startup.lua",
        "frekos/apps/update.lua",
        "frekos/apps/lockscreen.lua",
        "frekos/apps/welcome_screen.lua",

        -- endregion

        -- region { System files - Libraries }

        -- endregion

        -- region { Applications }

        "apps/storage.lua",
        "apps/teleport.lua",
        "apps/quartz_miner.lua",
        "apps/quartz_replacer.lua",

        -- endregion
    })

    print()
    print(hr())
    print()

    print("Install complete!")
    print()
    print()

    -- reboot()
end

function clear()
    term.clear()
    term.setCursorPos(1,1)
end

function hr()
    local w = term.getSize()
    return string.rep("-", w)
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
        save_path = "/" .. filepath
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

main()
