local creator = {
    registry = {},
    signals = {},
    defaultProperties = {
        ScreenGui = {
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        },
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ScrollingFrame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            ScrollBarImageColor3 = Color3.new(0, 0, 0),
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            ScrollingDirection = Enum.ScrollingDirection.Y
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            TextSize = 14,
        },
        TextButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
        },
        TextBox = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ClearTextOnFocus = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ImageButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
        },
        CanvasGroup = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
    },
}

creator.registry = setmetatable({}, { __mode = "k" })
creator.signals = setmetatable({}, { __mode = "k" })

function creator.addSignal(signal, callback)
    local connection = signal:Connect(callback)
    creator.signals[connection] = true
    return connection
end

function creator.removeSignal(connection)
    if connection then
        if connection.Connected then
            connection:Disconnect()
        end
        creator.signals[connection] = nil
    end
end

function creator.disconnect()
    for connection in creator.signals do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    creator.signals = setmetatable({}, { __mode = "k" })
end

function creator.getThemeProperty(property)
    local library = require("../")
    local themeName = library.theme

    return library.themes[themeName] and library.themes[themeName][property] or library.themes["dark"][property]
end

function creator.applyThemeProperty(object, property, value)
    object[property] = creator.getThemeProperty(value)
end

function creator.updateTheme()
    for object in creator.registry do
        if object and object.Parent then
            creator.applyTheme(object)
        end
    end
end

function creator.addThemeObject(object, properties)
    if not creator.registry[object] then
        creator.registry[object] = {}
    end

    for property, value in properties do
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

function creator.applyTheme(object)
    local themeTag = creator.registry[object]
    if not themeTag then return end

    for property, value in themeTag do
        pcall(function()
            creator.applyThemeProperty(object, property, value)
        end)
    end
end

function creator.new(name, properties, children)
    local object = Instance.new(name)

    for property, value in creator.defaultProperties[name] or {} do
        object[property] = value
    end

    if properties then
        local themeTag = properties.themeTag

        for property, value in properties do
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
        for _, child in children do
            if child then
                child.Parent = object
            end
        end
    end

    return object
end

return creator
