local serverHostname = "https://frekos.cc/api/frekos/"

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
	
	local file = fs.open(save_path, "w")
	file.write(fileContent)
	file.close()
	
	print("Download complete!\n")
	
	return true
end

download("update.lua", "/update.lua")
