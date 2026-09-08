local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Toggle"

function element:new(flag, config)
    assert(config.title, "toggle - missing title")

    local library = self.library
    local toggle = {
        type = "toggle",
        name = config.title,
        value = config.value or false,
        parent = self.parent,
        callback = config.callback or function() end
    }

    local toggleFrame = require("../components/element")(config.title, config.desc, self.container, true)
    toggleFrame.labelHolder.Size = UDim2.new(1, -60, 0, 0)

    function toggle:setTitle(text)
        return toggleFrame:setTitle(text)
    end

    function toggle:setDescription(text)
        return toggleFrame:setDescription(text)
    end

    function toggle:onChanged(func)
        toggle.changed = func
        func(toggle.value)
    end

    local switchThumb = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        themeTag = {
            BackgroundColor3 = "thumb",
            BackgroundTransparency = "thumbTransparency",
        }
    }, {
        new("UICorner", {
            CornerRadius = UDim.new(1, 0),
        })
    })

    local switch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 12),
        Parent = toggleFrame.frame,
        themeTag = {
            BackgroundColor3 = "track",
            BackgroundTransparency = "trackTransparency",
        }
    }, {
        switchThumb,
        new("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
        }),
        new("UIStroke", {
            Thickness = 0.5,
            themeTag = {
                Color = "track",
                Transparency = "trackTransparency",
            }
        })
    })

    function toggle:setValue(value)
        value = not not value
        toggle.value = value

        if value then
            creator.addThemeObject(switch, {
                BackgroundColor3 = "accent",
                BackgroundTransparency = "accentTransparency",
            })

            creator.addThemeObject(switch.UIStroke, {
                Color = "accent",
                Transparency = "accentTransparency",
            })

            creator.addThemeObject(switchThumb, {
                BackgroundColor3 = "thumb",
                BackgroundTransparency = "thumbActiveTransparency",
            })

            tween.play(switch, {
                BackgroundColor3 = creator.getThemeProperty("accent"),
                BackgroundTransparency = creator.getThemeProperty("accentTransparency"),
            }, { duration = 0.2 })

            tween.play(switch.UIStroke, {
                Color = creator.getThemeProperty("accent"),
                Transparency = creator.getThemeProperty("accentTransparency"),
            }, { duration = 0.2 })

            tween.play(switchThumb, {
                BackgroundColor3 = creator.getThemeProperty("thumb"),
                BackgroundTransparency = creator.getThemeProperty("thumbActiveTransparency"),
                Position = UDim2.new(0, 12, 0.5, 0)
            }, { duration = 0.2 })
        else
            creator.addThemeObject(switch, {
                BackgroundColor3 = "track",
                BackgroundTransparency = "trackTransparency",
            })

            creator.addThemeObject(switch.UIStroke, {
                Color = "track",
                Transparency = "trackTransparency",
            })

            creator.addThemeObject(switchThumb, {
                BackgroundColor3 = "thumb",
                BackgroundTransparency = "thumbTransparency",
            })

            tween.play(switch, {
                BackgroundColor3 = creator.getThemeProperty("track"),
                BackgroundTransparency = creator.getThemeProperty("trackTransparency"),
            }, { duration = 0.2 })

            tween.play(switch.UIStroke, {
                Color = creator.getThemeProperty("track"),
                Transparency = creator.getThemeProperty("trackTransparency"),
            }, { duration = 0.2 })

            tween.play(switchThumb, {
                BackgroundColor3 = creator.getThemeProperty("thumb"),
                BackgroundTransparency = creator.getThemeProperty("thumbTransparency"),
                Position = UDim2.new(0, 0, 0.5, 0)
            }, { duration = 0.2 })
        end

        library:safeCallback(toggle.callback, toggle.value)
        library:safeCallback(toggle.changed, toggle.value)
    end

    function toggle:destroy()
        toggleFrame:destroy()
        library.options[flag] = nil
    end

    addSignal(toggleFrame.root.activated, function()
        toggle:setValue(not toggle.value)
    end)

    toggle:setValue(toggle.value)
    library.options[flag] = toggle
    return toggle
end

return element
