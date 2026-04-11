local content, getErr = http.get(frekos.settings.update_url)
if not content then
    printError("An error occurred while fetching the updater:")
    printError(getErr)
end

local fn, loadErr = load(content)
if not fn then
    printError("An error occurred while loading the updater:")
    printError(loadErr)
end

local ok, runErr = pcall(fn, frekos.settings.device_uuid)
if not ok then
    printError("An error occurred while updating:")
    printError(runErr)
end
