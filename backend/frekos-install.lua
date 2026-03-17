local serverHostname = "https://frekos.cc/api/computercraft/"

function main()
    download("startup.lua", "/startup.lua")

    -- region { System files - Applications }

    download("frekos/apps/startup.lua", "/frekos/apps/startup.lua")
    download("frekos/apps/update.lua", "/frekos/apps/update.lua")
    download("frekos/apps/lockscreen.lua", "/frekos/apps/lockscreen.lua")
    download("frekos/apps/welcome_screen.lua", "/frekos/apps/welcome_screen.lua")

    -- endregion

    -- region { System files - Libraries }

    -- endregion

    -- region { Applications }

    download("apps/storage.lua", "/apps/storage.lua")

    -- endregion


    print("\n\nInstall complete!\n\n")
    -- reboot()
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

function download(filepath, save_path)
	print("Downloading file '"..filepath.."' as '"..save_path.."'!")
	local fileContent = get(serverHostname..filepath)
	
	if (fileContent == nil) then
		print("Download failed!\n")
		return false
	end

	if (fs.exists(save_path)) then
		fs.delete(save_path)
	end

	ensureDir(save_path)

	local file = fs.open(save_path, "w")
	file.write(fileContent)
	file.close()
	
	print("Download complete!\n")
	
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
