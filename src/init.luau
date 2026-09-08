local runService = game:GetService("RunService")
local localPlayer = game:GetService("Players").LocalPlayer

local creator = require(script.modules.creator)
local elementsTable = require(script.elements)
local notificationModule = require(script.components.notification)

local new = creator.new

local protectGui = protectgui or (syn and syn.protect_gui) or function() end
local gui = new("ScreenGui", {
    Parent = runService:IsStudio() and localPlayer.PlayerGui or game:GetService("CoreGui"),
})

protectGui(gui)
notificationModule:init(gui)

local library = {
    name = "Hirimi",
    version = "1.0.0",
    window = nil,
    options = {},
    themes = require(script.themes),
    theme = "Dark",
    id = 0,
    gui = gui
}

function library:safeCallback(callback, ...)
    if not callback then
        return
    end

    local success, event = pcall(callback, ...)
    if not success then
        local _, i = event:find(":%d+: ")

        if not i then
            return library:notify({
                title = "Callback error",
                desc = event,
                duration = 5,
            })
        end

        return library:notify({
            title = "Callback error",
            desc = event:sub(1, i),
            duration = 5,
        })
    end

    return success
end

function library:generateUniqueId()
    self.id += 1
    return self.id
end

function library:mergeDictionaries(default, user)
    if not user then
        return default
    end

    local result = {}

    for key, value in default do
        if type(value) == "table" and type(user[key]) == "table" then
            result[key] = self:mergeDictionaries(value, user[key])
        else
            result[key] = user[key] ~= nil and user[key] or value
        end
    end

    for key, value in user do
        if result[key] == nil then
            result[key] = value
        end
    end

    return result
end

local icons = require(script.modules.icons).assets

function library:getIcon(name)
    return name ~= nil and icons["lucide-" .. name] or nil
end

local elements = {}

elements.__index = elements
elements.__namecall = function(table, key, ...)
    return elements[key](...)
end

for _, elementComponent in elementsTable do
    elements["add" .. elementComponent.__type] = function(self, flag, config)
        if self.type == "tab" then
            elementComponent.container = self.container.container
        else
            elementComponent.container = self.container
        end
        elementComponent.parent = self
        elementComponent.type = self.type
        elementComponent.library = library

        return elementComponent:new(flag, config)
    end
end

library.elements = elements

function library:createWindow(config)
    if library.window then
        warn("You cannot create more than one window.")
        return
    end

    local defaultConfig = {
        title = 'Hirimi Library',
        sidebar = {
            width = 160
        },
        size = {
            responsive = false,
            dragSizeable = true,
            scale = 0.7,
        },
        theme = 'dark',
        acrylic = true,
        realtimeResize = true,
        keybind = Enum.KeyCode.LeftControl,
    }

    self:mergeDictionaries(defaultConfig, config)

    config.library = library
    config.parent = gui

    local window = require(script.components.window)(config)

    library.window = window
    library:setTheme(config.theme)

    return window
end

function library:setTheme(value)
    if library.window and table.find(library.themes, value) then
        library.theme = value
        creator.updateTheme()
    end
end

function library:destroy()
    if library.window then
        creator.disconnect()
        library.gui:Destroy()
    end
end

function library:notify(config)
    return notificationModule:new(config)
end

if getgenv then
    getgenv()[library.name or "Hirimi"] = library
end

return library
