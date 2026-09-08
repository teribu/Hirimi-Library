local userInputService = game:GetService("UserInputService")

local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Input"

function element:new(flag, config)
    assert(config.title, "input - missing title")

    local library = self.library
    local input = {
        type = "input",
        name = config.title,
        value = config.value or "",
        placeHolder = config.placeHolder or "",
        clearTextOnFocus = config.clearTextOnFocus or false,
        realTime = config.realTime or false,
        parent = self.parent,
        callback = config.callback or function() end
    }

    local inputFrame = require("../components/element")(config.title, config.desc, self.container, false)
    inputFrame.labelHolder.Size = UDim2.new(1, -120, 0, 0)

    function input:setTitle(text)
        return inputFrame:setTitle(text)
    end

    function input:setDescription(text)
        return inputFrame:setDescription(text)
    end

    local inputBox = new("TextBox", {
        ClearTextOnFocus = input.clearTextOnFocus,
        CursorPosition = -1,
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        PlaceholderText = input.placeHolder,
        RichText = true,
        Text = input.value,
        TextSize = 8,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 1, 0),
        themeTag = {
            PlaceholderColor3 = "placeHolder",
            TextColor3 = "optionText",
            TextTransparency = "optionTextTransparency"
        }
    })

    local inputDisplay = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 90, 0, 20),
        Parent = inputFrame.root,
        themeTag = {
            BackgroundColor3 = "option",
            BackgroundTransparency = "optionTransparency"
        }
    }, {
        inputBox,
        new("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }),
        new("UIStroke", {
            Thickness = 0.6,
            themeTag = {
                Color = "optionBorder",
                Transparency = "optionBorderTransparency"
            }
        }),
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)
        })
    })

    function input:onChanged(func)
        input.changed = func
        func(input.value)
    end

	function input:setValue(value)
	    inputBox.Text = tostring(value)

	    library:safeCallback(input.callback, value)
	    library:safeCallback(input.changed, value)
	end

    function input:destroy()
        inputFrame:destroy()
        library.options[flag] = nil
    end

    addSignal(inputBox.Focused, function()
        creator.addThemeObject(inputDisplay, {
            BackgroundTransparency = 'optionHoverActiveTransparency'
        })

        tween.play(inputDisplay, {
            BackgroundTransparency = creator.getThemeProperty('optionHoverActiveTransparency')
        }, { duration = 0.2 })
    end)

    addSignal(inputBox:GetPropertyChangedSignal("Text"), function()
        if input.realTime then
            input:setValue(inputBox.Text)
        end
    end)

    addSignal(inputBox.FocusLost, function()
        creator.addThemeObject(inputDisplay, {
            BackgroundTransparency = 'optionTransparency'
        })

        tween.play(inputDisplay, {
            BackgroundTransparency = creator.getThemeProperty('optionTransparency')
        }, { duration = 0.2 })

        if not input.realTime then
            input:setValue(inputBox.Text)
        end
    end)

    input:setValue(input.value)
    library.options[flag] = input
    return input
end

return element
