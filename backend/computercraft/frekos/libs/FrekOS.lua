local api = {}

function api.refreshSettings()
    api.settings = fileUtils.loadConfig("/frekos/settings.table")
end


function beforeLoad()
    print("Loading settings...")
   api.refreshSettings()
end

function afterLoad()

end

return api, beforeLoad, afterLoad
