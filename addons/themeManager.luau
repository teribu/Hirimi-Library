local themeManager = {
    folder = "Library",
    oldThemes = {},
    library = nil
}

function themeManager:ensureFolder(onlyCheck)
    if onlyCheck then
        return isfolder(self.folder) and isfolder(self.folder .. "/Themes")
    end

    if not isfolder(self.folder) then
        makefolder(self.folder)
    end

    local themeFolder = self.folder .. "/Themes"
    if not isfolder(themeFolder) then
        makefolder(themeFolder)
    end
    return themeFolder
end

function themeManager:getThemes()
    local themesFolder = self:ensureFolder()
    if not themesFolder then
        return {}
    end

    local themes = table.clone(self.oldThemes)
    for _, file in listfiles(themesFolder) do
        local name = file:match("([^/\\]+)%.json$")

        if name then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(file))

            if ok then
                themes[name] = data
            else
                warn(("[ themeManager ] Failed to load theme '%s'"):format(file))
            end
        end
    end

    return themes
end

function themeManager:refreshList()
    self.library.Themes = self:getThemes()
end

function themeManager:init(library)
    if themeManager.library then
        warn("[ themeManager ] themeManager is already initialized")
        return
    end

    themeManager.library = library
    themeManager.oldThemes = library.themes

    if library.name and type(library.name) == "string" then
        themeManager.folder = library.name
    end

    themeManager:refreshList()
    themeManager.library:setTheme(themeManager.library.theme)
end

return themeManager
