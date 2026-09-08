local userInputService = game:GetService("UserInputService")

local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Slider"

function element:new(flag, config)
    assert(config.title, "slider - missing title")

    local library = self.library
    local slider = {
        type = "slider",
        name = config.title,
        value = config.value or config.min or 0,
        min = config.min or 0,
        max = config.max or 100,
        step = config.step or 1,
        suffix = config.suffix or "",
        parent = self.parent,
        clearTextOnFocus = config.clearTextOnFocus or false,
        textEditable = config.textEditable or false,
        realTime = config.realTime or false,
        sliderWidth = config.sliderWidth or 70,
        callback = config.callback or function() end
    }

    local sliderFrame = require("../components/element")(config.title, config.desc, self.container, false)
    sliderFrame.labelHolder.Size = UDim2.new(1, -slider.sliderWidth-50, 0, 0)

    function slider:setTitle(text)
        return sliderFrame:setTitle(text)
    end

    function slider:setDescription(text)
        return sliderFrame:setDescription(text)
    end

    local sliderBox = new("TextBox", {
        ClearTextOnFocus = slider.clearTextOnFocus,
        CursorPosition = -1,
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        PlaceholderText = "0" .. slider.suffix,
        RichText = true,
        Text = tostring(slider.value) .. slider.suffix,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 12),
        TextEditable = slider.textEditable,
        themeTag = {
            PlaceholderColor3 = "optionText",
            TextColor3 = "optionText",
            TextTransparency = "optionTextTransparency"
        }
    })

    local sliderDisplay = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(1, -slider.sliderWidth-5, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = sliderFrame.root,
    }, {
        sliderBox,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 5)
        })
    })

    local sliderDot = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 3, 0.5, 0),
        Size = UDim2.new(0, 6, 0, 6),
        themeTag = {
            BackgroundColor3 = "accent"
        }
    }, {
        new("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    local sliderFill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        themeTag = {
            BackgroundColor3 = "accent"
        }
    }, {
        sliderDot,
        new("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    local sliderTrack = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(1, -10, 0, 2),
        themeTag = {
            BackgroundColor3 = "track",
            BackgroundTransparency = "trackTransparency",
        }
    }, {
        sliderFill,
        new("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    local sliderHolder = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, slider.sliderWidth, 1, 0),
        Parent = sliderFrame.root
    }, {
        sliderTrack
    })

    function slider:_round(number, factor)
		local result = math.floor(number / factor + (math.sign(number) * 0.5)) * factor
		if result < 0 then
			result = result + factor
		end
		return result
	end

	local isUpdating = false
	local dragging = false

	addSignal(sliderBox:GetPropertyChangedSignal("Text"), function()
        if isUpdating then return end
        isUpdating = true

        local cleanedText = sliderBox.Text:gsub("[^%d%.]", "")

        local firstDot = cleanedText:find("%.")
        if firstDot and cleanedText:find("%.", firstDot + 1) then
            cleanedText = cleanedText:sub(1, firstDot) .. cleanedText:sub(firstDot + 1):gsub("%.", "")
        end

        local numValue = tonumber(cleanedText)
        if numValue and numValue > slider.max then
            sliderBox.Text = tostring(slider.max) .. slider.suffix
        else
            sliderBox.Text = cleanedText .. slider.suffix
        end

        isUpdating = false
    end)

	addSignal(sliderBox.FocusLost, function()
	    if not slider.realTime then
	        local cleanText = sliderBox.Text:gsub("[^%d%.]", "")
	        local finalValue = tonumber(cleanText) or slider.min

	        slider:setValue(finalValue)
	    end
	end)

	addSignal(sliderHolder.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
		end
	end)

	addSignal(sliderHolder.InputEnded, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
			if not slider.realTime then
				local SizeScale = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
				slider:setValue(slider.min + ((slider.max - slider.min) * SizeScale))
			end
		end
	end)

	addSignal(userInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local sizeScale = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
			local value = math.clamp(slider:_round(slider.min + ((slider.max - slider.min) * sizeScale), slider.step), slider.min, slider.max)

			if slider.realTime then
				slider:setValue(value)
			else
                local stepStr = tostring(slider.step)
                local dotIndex = stepStr:find("%.")
                local decimalPlaces = dotIndex and (#stepStr - dotIndex) or 0
                local cleanDisplayValue = tonumber(string.format("%." .. decimalPlaces .. "f", value))

                sliderBox.Text = tostring(cleanDisplayValue) .. slider.suffix
                tween.play(sliderFill, { Size = UDim2.fromScale((value - slider.min) / (slider.max - slider.min), 1) }, { duration = 0.25 })
            end
		end
	end)

    function slider:onChanged(func)
        slider.changed = func
        func(slider.value)
    end

	function slider:setValue(value)
		local computedValue = math.clamp(slider:_round(value, slider.step), slider.min, slider.max)

		local stepStr = tostring(slider.step)
		local dotIndex = stepStr:find("%.")
		local decimalPlaces = dotIndex and (#stepStr - dotIndex) or 0

		local cleanValue = tonumber(string.format("%." .. decimalPlaces .. "f", computedValue))

		slider.value = cleanValue
		sliderBox.Text = tostring(cleanValue) .. slider.suffix
		tween.play(sliderFill, { Size = UDim2.fromScale((cleanValue - slider.min) / (slider.max - slider.min), 1) }, { duration = 0.25 })

		library:safeCallback(slider.callback, slider.value)
		library:safeCallback(slider.changed, slider.value)
	end

    function slider:destroy()
        sliderFrame:destroy()
        library.options[flag] = nil
    end

    slider:setValue(slider.value)
    library.options[flag] = slider
    return slider
end

return element
