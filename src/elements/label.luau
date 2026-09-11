local creator = require("../modules/creator")
local new = creator.new

local element = {}
element.__index = element
element.__type = "Label"

function element:new(text)
    assert(text, "label - missing text")

    local library = self.library
    local label = {
        type = "label",
        name = text,
        parent = self.parent
    }

    local labelText = new("TextLabel", {
        Text = "Interfaces",
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        themeTag = {
            TextColor3 = "primary",
            TextTransparency = "primaryTransparency",
        }
    })

    local labelFrame = new("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 10),
        Parent = self.container
    }, {
        labelText,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 0),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 3),
        }),
    })

    function label:setText(text)
        labelText.Text = text
    end

    function label:destroy()
        return labelFrame:Destroy()
    end

    label.rootFrame = labelFrame
    if library then
        library.options[library:generateUniqueId()] = label
    end
    return label
end

return element
