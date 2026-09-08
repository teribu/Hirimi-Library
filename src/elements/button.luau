local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Button"

function element:new(config)
    assert(config.title, "button - missing title")

    local button = {
        type = "button",
        name = config.title,
        parent = self.parent,
        callback = config.callback or function() end
    }

    local library = self.library
    local buttonFrame = require("../components/element")(config.title, config.desc, self.container, true)
    buttonFrame.labelHolder.Size = UDim2.new(1, -50, 0, 0)

    function button:setTitle(text)
        return buttonFrame:setTitle(text)
    end

    function button:setDescription(text)
        return buttonFrame:setDescription(text)
    end

    function button:destroy()
        return buttonFrame:destroy()
    end

    local sectionIcon = new("ImageLabel", {
        Image = "rbxassetid://10709791437",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Parent = buttonFrame.root,
        themeTag = {
            ImageColor3 = "secondary",
            ImageTransparency = "secondaryTransparency",
        }
    })

    addSignal(buttonFrame.root.Activated, button.callback)

    if library then
        library.options[library:generateUniqueId()] = button
    end

    return button
end

return element
