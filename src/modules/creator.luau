local creator = {
    registry = {},
    signals = {},
    defaultProperties = {
        ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
        Frame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
        ScrollingFrame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ScrollBarImageColor3 = Color3.new(0, 0, 0), ScrollBarThickness = 0, ScrollBarImageTransparency = 1, ScrollingDirection = Enum.ScrollingDirection.Y },
        TextLabel = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, TextSize = 14 },
        TextButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
        TextBox = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), ClearTextOnFocus = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
        ImageButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false },
        CanvasGroup = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
    },
}

creator.signals = setmetatable({}, { __mode = "k" })

function creator.addSignal(signal, callback)
    local connection = signal:Connect(callback)
    creator.signals[connection] = true
    return connection
end

function creator.removeSignal(connection)
    if connection then
        if connection.Connected then connection:Disconnect() end
        creator.signals[connection] = nil
    end
end

function creator.disconnect()
    for connection in pairs(creator.signals) do
        if connection.Connected then connection:Disconnect() end
    end
    creator.signals = setmetatable({}, { __mode = "k" })
end

function creator.getThemeProperty(property)
    local library = require("../")
    local currentTheme = library.themes[library.theme]
    local darkTheme = library.themes["dark"] or {}

    if currentTheme and currentTheme[property] ~= nil then
        return currentTheme[property]
    end
    return darkTheme[property]
end

function creator.applyThemeProperty(object, property, value)
    local themeVal = creator.getThemeProperty(value)
    if themeVal ~= nil then
        object[property] = themeVal
    end
end

function creator.applyTheme(object)
    local themeTag = creator.registry[object]
    if not themeTag then return end

    for property, value in pairs(themeTag) do
        pcall(function()
            creator.applyThemeProperty(object, property, value)
        end)
    end
end

function creator.updateTheme()
    for object in pairs(creator.registry) do
        if object and object.Parent then
            creator.applyTheme(object)
        else
            creator.registry[object] = nil
        end
    end
end

function creator.addThemeObject(object, properties)
    if not creator.registry[object] then
        creator.registry[object] = {}

        object.Destroying:Connect(function()
            creator.registry[object] = nil
        end)
    end

    for property, value in pairs(properties) do
        creator.registry[object][property] = value
    end

    return object
end

function creator.removeThemeObject(object, properties)
    if not creator.registry[object] then
        creator.registry[object] = {}
    end

    for property, value in properties do
        creator.registry[object][property] = nil
    end
    return object
end

function creator.new(name, properties, children)
    local object = Instance.new(name)

    for property, value in pairs(creator.defaultProperties[name] or {}) do
        object[property] = value
    end

    if properties then
        local themeTag = properties.themeTag

        for property, value in pairs(properties) do
            if property ~= "themeTag" then
                object[property] = value
            end
        end

        if themeTag then
            creator.addThemeObject(object, themeTag)
            creator.applyTheme(object)
        end
    end

    if children then
        for _, child in pairs(children) do
            if child then child.Parent = object end
        end
    end

    return object
end

return creator
