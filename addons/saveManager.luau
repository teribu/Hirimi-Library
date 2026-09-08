local httpService = game:GetService("HttpService")
local saveManager = {
    folder = "Library",
    username = game:GetService("Players").LocalPlayer.Name,
    library = nil,
    data = {}
}

function saveManager:ensureFolder(onlyCheck)
    if onlyCheck then
        return isfolder(self.folder) and isfolder(self.folder .. "/configs") and isfolder(self.folder .. "/configs/" .. self.username)
    end

    if not isfolder(self.folder) then
        makefolder(self.folder)
    end

    local configsFolder = self.folder .. "/configs"
    if not isfolder(configsFolder) then
        makefolder(configsFolder)
    end

    local userFolder = configsFolder .. "/" .. self.username
    if not isfolder(userFolder) then
        makefolder(userFolder)
    end

    return userFolder
end

function saveManager:save()
    local path = self:ensureFolder() .. "/config.json"
    local ok, encoded = pcall(httpService.JSONEncode, httpService, self.data)

    if not ok then
        warn("[ saveManager ] Failed to encode config")
        return
    end

    return writefile(path, encoded)
end

function saveManager:load()
    if not saveManager.library then
        return
    end

    if not self:ensureFolder(true) then
        return
    end

    local path = self.folder .. "/Configs/" .. self.username .. "/config.json"
    if not isfile(path) then
        return
    end

    local ok, data = pcall(httpService.JSONDecode, httpService, readfile(path))

    if not ok then
        warn("[ saveManager ] Invalid config")
        return
    end

    for flag, value in data do
        local option = self.library.options[flag]

        if option and option.setValue then
            option:setValue(value)
        end
    end

    return data
end

function saveManager:init(library)
    if saveManager.library then
        warn("[ saveManager ] saveManager is already initialized")
        return
    end

    saveManager.library = library

    if library.name and type(library.name) == "string" then
        saveManager.folder = library.name
    end

    local initializing = true

    for flag, element in library.options do
        if element.value and element.setValue and element.onChanged then
            saveManager.data[flag] = element.value

            element:onChanged(function(value)
                saveManager.data[flag] = value

                if not initializing then
                    saveManager:save()
                end
            end)
        end
    end

    initializing = false
    saveManager:load()
    return true
end

return saveManager
