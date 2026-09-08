local camera = game:GetService("Workspace").CurrentCamera

local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local notification = {
    scale = 0.26,
    totalNotifications = 0
}

function notification:init(gui)
    notification.scaler = new("UIScale", {
        Scale = 1
    })

    notification.holder = new("Frame", {
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 240, 1, -60),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = gui,
    }, {
        notification.scaler,
        new("UIListLayout", {
            Padding = UDim.new(0, 5),
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    local function updateScale()
        local currentSize = notification.holder.AbsoluteSize
        if currentSize.X == 0 or currentSize.Y == 0 then return end

    	local baseWidth = currentSize.X / notification.scaler.Scale
    	local maxAllowedWidth = camera.ViewportSize.X * notification.scale

    	notification.scaler.Scale = maxAllowedWidth / baseWidth
    end

    updateScale()
    addSignal(camera:GetPropertyChangedSignal("ViewportSize"), updateScale)

    return true
end

function notification:new(config)
    local newNotification = {
        closed = false
    }

    config.duration = config.duration or 5
    notification.totalNotifications += 1

    newNotification.title = new("TextLabel", {
        TextWrapped = true,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        BackgroundTransparency = 1,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 0),
        Text = config.title or "Notification",
        AutomaticSize = Enum.AutomaticSize.Y,
        themeTag = {
            TextColor3 = "primary",
            TextTransparency = "primaryTransparency"
        }
    })

    newNotification.labelHolder = new("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
    }, {
        newNotification.title,
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

    if config.desc then
        newNotification.desc = new("TextLabel", {
            TextWrapped = true,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            Text = config.desc,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = newNotification.labelHolder,
            themeTag = {
                TextColor3 = "secondary",
                TextTransparency = "secondaryTransparency"
            }
        })
    end

    newNotification.root = new("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.Y,
        themeTag = {
            BackgroundColor3 = "background",
            BackgroundTransparency = "backgroundTransparency"
        }
    }, {
        newNotification.labelHolder,
        new("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        new("UIShadow", {
            BlurRadius = UDim.new(0, 20),
            themeTag = {
                Color = "shadow",
                Transparency = "shadowTransparency"
            }
        })
    })

    newNotification.holder = new("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = -notification.totalNotifications,
        Parent = notification.holder,
    }, {
        newNotification.root
    })

    newNotification.root.Position = UDim2.new(0, (notification.holder.AbsoluteSize.X / notification.scaler.Scale) + 40, 0, 0)
    function newNotification:Open()
        tween.play(newNotification.root,
            { Position = UDim2.new(0, 0, 0, 0) },
            { Duration = 0.5, EasingStyle = "Exponential" }
        )
    end

    function newNotification:Close()
        if newNotification.Closed then return end
        newNotification.Closed = true

        addSignal(
            tween.play(newNotification.root,
                { Position = UDim2.new(0, newNotification.holder.AbsoluteSize.X + 40, 0, 0) },
                { Duration = 0.2 }
            ).Completed, function()
                newNotification.holder.Size = UDim2.new(1, 0, 0, newNotification.holder.AbsoluteSize.Y / notification.scaler.Scale)
                newNotification.holder.AutomaticSize = Enum.AutomaticSize.None

                addSignal(tween.play(newNotification.holder, { Size = UDim2.new(1, 0, 0, 0) }, { Duration = 0.1, EasingStyle = "Quad" }).Completed, function()
                    newNotification.holder:Destroy()
                end)
            end
        )
    end

    task.spawn(function()
        newNotification:Open()
        task.wait(config.duration)
        newNotification:Close()
    end)

    return newNotification
end

return notification
