local creator = require('../modules/creator')
local tween = require('../modules/tween')

local new = creator.new
local addSignal = creator.addSignal

return function (title, desc, parent, hover)
    local element = {
        hovering = false,
    }

    element.title = new("TextLabel", {
        TextWrapped = true,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 10),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = title,
        themeTag = {
            TextColor3 = "primary",
            TextTransparency = "primaryTransparency"
        }
    })

    element.labelHolder = new("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -120, 0, 0),
    }, {
        element.title,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 9),
            PaddingBottom = UDim.new(0, 9),
        }),
        new("UIListLayout", {
            Padding = UDim.new(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    element.frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 29),
        AutomaticSize = Enum.AutomaticSize.Y,
        themeTag = {
            BackgroundColor3 = "element",
            BackgroundTransparency = "elementTransparency"
        }
    }, {
        element.labelHolder,
        new("UICorner", {
            CornerRadius = UDim.new(0, 6)
        })
    })

    element.root = new("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, 29),
        Parent = parent,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    }, {
        element.frame,
    })

    function element:setTitle(title)
        element.title.Text = title
    end

    function element:setDescription(description)
        if not element.description then
            element.description = new("TextLabel", {
                Text = description,
                TextWrapped = true,
                TextSize = 10,
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1,
                BackgroundTransparency = 1,
                RichText = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                Parent = element.labelHolder,
                themeTag = {
                    TextColor3 = "secondary",
                    TextTransparency = "secondaryTransparency"
                }
            })
        end

        element.description.Text = description
    end

    element:setTitle(title)
    if desc then
        element:setDescription(desc)
    end

    function element:destroy()
        element.root:Destroy()
    end

    if hover then
        addSignal(element.root.MouseEnter, function()
            element.hovering = true

            creator.addThemeObject(element.frame, {
                BackgroundTransparency = 'elementHoverTransparency'
            })

            tween.play(element.frame, {
                BackgroundTransparency = creator.getThemeProperty('elementHoverTransparency')
            })
        end)

        addSignal(element.root.MouseLeave, function()
            element.hovering = false

            creator.addThemeObject(element.frame, {
                BackgroundTransparency = 'elementTransparency'
            })

            tween.play(element.frame, {
                BackgroundTransparency = creator.getThemeProperty('elementTransparency')
            })
        end)
    end

    return element
end
