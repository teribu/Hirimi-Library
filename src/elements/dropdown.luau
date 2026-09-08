local userInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Dropdown"

function element:new(flag, config)
    assert(config.title, "input - missing title")

    local library = self.library
    local window = library.window

    local dropdown = {
        type = "dropdown",
        name = config.title,
        options = config.options or {},
        multi = config.multi or false,
        value = (config.multi and (config.value or {})) or (config.value or ""),
        totalButtons = 0,
        buttons = {},
        parent = self.parent,
        opened = false,
        openWidth = config.openWidth or 92,
        openHeight = config.openHeight or 200,
        callback = config.callback or function() end
    }

    if dropdown.multi then
        local newValue = {}
        for _, value in dropdown.options do
            newValue[value] = dropdown.value[value] and true or table.find(dropdown.value, value) and true or false
        end

        dropdown.value = newValue
    end

    local container = self.container
    local dropdownFrame = require("../components/element")(config.title, config.desc, container, false)
    dropdownFrame.labelHolder.Size = UDim2.new(1, -120, 0, 0)

    function dropdown:setTitle(text)
        return dropdownFrame:setTitle(text)
    end

    function dropdown:setDescription(text)
        return dropdownFrame:setDescription(text)
    end

    local dropdownIcon = new("ImageLabel", {
        Image = "rbxassetid://10709790948",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        themeTag = {
            ImageColor3 = "optionText",
            ImageTransparency = "optionTextTransparency"
        }
    })

    local dropdownText = new("TextLabel", {
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        RichText = true,
        Text = "None",
        TextSize = 8,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -15, 0, 8),
        themeTag = {
            TextColor3 = "optionText",
            TextTransparency = "optionTextTransparency"
        }
    })

    local dropdownButton = new("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = parent,
        BackgroundTransparency = 1,
    }, {
        dropdownText,
        dropdownIcon,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)
        })
    })

    local dropdownDisplay = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 90, 0, 20),
        Parent = dropdownFrame.root,
        themeTag = {
            BackgroundColor3 = "option",
            BackgroundTransparency = "optionTransparency"
        }
    }, {
        dropdownButton,
        new("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }),
        new("UIStroke", {
            Thickness = 0.6,
            themeTag = {
                Color = "optionBorder",
                Transparency = "optionBorderTransparency"
            }
        })
    })

    local optionHolder = new("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        themeTag = {
            ScrollBarImageColor3 = "scrollBarImage",
            ScrollBarImageTransparency = "scrollBarImageTransparency"
        }
    }, {
        new("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0)
        })
    })

    local dropdownHolderFrame = new("Frame", {
		Size = UDim2.fromScale(1, 0.4),
		themeTag = {
			BackgroundColor3 = "dropdown",
			Transparency = "dropdownTransparency"
		},
	}, {
	    optionHolder,
		new("UICorner", {
			CornerRadius = UDim.new(0, 5)
		}),
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 0),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5)
		}),
	    new("UIShadow", {
			BlurRadius = UDim.new(0, 20),
	        themeTag = {
	            Color = "dropdownShadow",
	            Transparency = "dropdownShadowTransparency"
	        }
	    }),
	    new("UIStroke", {
			Thickness = 0.5,
	        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	        themeTag = {
	            Color = "dropdownBorder",
	            Transparency = "dropdownBorderTransparency"
	        }
	    })
	})

    local dropdownHolderCanvas = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(dropdown.openWidth, dropdown.openHeight),
		Parent = window.root,
		Visible = false
	}, {
		dropdownHolderFrame,
		new("UISizeConstraint", {
			MinSize = Vector2.new(dropdown.openWidth, 0),
		})
	})

    local function recalculateListPosition()
        local scale = window.scaler.Scale or 1
        local displayPos = dropdownDisplay.AbsolutePosition
        local displaySize = dropdownDisplay.AbsoluteSize
        local rootPos = window.root.AbsolutePosition

        local maxCanvasHeight = optionHolder.UIListLayout.AbsoluteContentSize.Y

        local x = (displayPos.X - rootPos.X) / scale
        local y = (displayPos.Y - rootPos.Y) / scale
        local displayHeight = displaySize.Y / scale

        local targetCanvasHeight = 20 +
            ((#dropdown.options > 8 and dropdown.openHeight)
            or (maxCanvasHeight / scale))

        local viewportHeight = camera.ViewportSize.Y / scale
        local rootY = rootPos.Y / scale

        local overflow = y + displayHeight + targetCanvasHeight
            - (viewportHeight - rootY)

        if overflow > 0 then
            y -= overflow
        end

        dropdownHolderCanvas.Position = UDim2.fromOffset(x, y)
    end

    local listSizeX = 0

    local function recalculateListSize()
       	local scale = window.scaler.Scale
    	if #dropdown.options > 8 then
    		dropdownHolderCanvas.Size = UDim2.fromOffset(
    			listSizeX,
    			dropdown.openHeight
    		)
    	else
    		dropdownHolderCanvas.Size = UDim2.fromOffset(
    			listSizeX,
    			(optionHolder.UIListLayout.AbsoluteContentSize.Y / scale) + 11
    		)
    	end
    end

    recalculateListSize()
    recalculateListPosition()

    addSignal(dropdownDisplay:GetPropertyChangedSignal("AbsolutePosition"), recalculateListPosition)

    function dropdown:open()
        recalculateListSize()
        recalculateListPosition()
        dropdown.opened = true
        window.sidebar.tabContainer.tabHolder.ScrollingEnabled = false
        container.ScrollingEnabled = false
        dropdownHolderCanvas.Visible = true
        tween.play(dropdownHolderFrame, { Size = UDim2.fromScale(1, 1) }, { duration = 0.15 })
    end

    function dropdown:close()
        dropdown.opened = false
        window.sidebar.tabContainer.tabHolder.ScrollingEnabled = true
        container.ScrollingEnabled = true
        dropdownHolderCanvas.Visible = false
        dropdownHolderFrame.Size = UDim2.fromScale(1, 0.4)
    end

    function dropdown:build()
        for _, button in self.buttons do
            if button.destroy then
                button:destroy()
            end
        end

        self.totalButtons = 0
        self.buttons = {}

        for _, value in self.options do
            self.totalButtons += 1

            local isSelected = false
				if self.multi then
                isSelected = self.value[value] == true
            else
                isSelected = self.value == value
            end

            self.buttons[value] = {
                value = isSelected,
                hovering = false
            }

            local button = self.buttons[value]

            button.title = new("TextLabel", {
                Text = tostring(value),
                Size = UDim2.new(1, 0, 0, 8),
                TextSize = 8,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                LayoutOrder = self.totalButtons,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                AutomaticSize = Enum.AutomaticSize.Y,
                themeTag = {
                    TextColor3 = "optionText",
                    TextTransparency = "optionTextNotActiveTransparency"
                }
            })

            button.frame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.Y,
                themeTag = {
                    BackgroundColor3 = "option",
                    BackgroundTransparency = "optionNotActiveTransparency"
                }
            }, {
                button.title,
                new("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }),
                new("UIPadding", {
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 6)
                })
            })

            button.indicator = new("Frame", {
                Size = UDim2.new(0, 2, 0, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 1,
                themeTag = {
                    BackgroundColor3 = "accent",
                }
            }, {
                new("UICorner", {
                    CornerRadius = UDim.new(0, 30),
                }),
                new("ImageLabel", {
                    Size = UDim2.new(1, 20, 1, 20),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Image = "rbxassetid://8992230677",
                    SliceCenter = Rect.new(99, 99, 99, 99),
                    ImageTransparency = 1,
                    themeTag = {
                        ImageColor3 = "accent",
                    }
                })
            })

            button.root = new("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = optionHolder
            }, {
                button.frame,
                button.indicator
            })

            addSignal(button.frame.MouseEnter, function()
                button.hovering = true

                creator.addThemeObject(button.frame, {
                    BackgroundTransparency = button.value and "optionHoverActiveTransparency" or "optionHoverTransparency"
                })

                tween.play(button.frame, {
                    BackgroundTransparency = button.value and creator.getThemeProperty("optionHoverActiveTransparency") or creator.getThemeProperty("optionHoverTransparency")
                })
            end)

            addSignal(button.frame.MouseLeave, function()
                button.hovering = false

                creator.addThemeObject(button.frame, {
                    BackgroundTransparency = button.value and "optionTransparency" or "optionNotActiveTransparency"
                })

                tween.play(button.frame, {
                    BackgroundTransparency = button.value and creator.getThemeProperty("optionTransparency") or creator.getThemeProperty("optionNotActiveTransparency")
                })
            end)

            addSignal(button.root.Activated, function()
                if self.multi then
                    self.value[value] = not self.value[value] or nil
                    self:setValue(self.value)
                else
                    self:setValue(value)
                end
            end)

            function button:destroy()
                if button.root then button.root:Destroy() end
            end
        end

        recalculateListSize()
    end

	function dropdown:updateValue()
	    if #self.options == self.totalButtons then
			for value, button in self.buttons do
				if type(button) == "table" then
				    local isSelected = false
					if self.multi then
                        isSelected = self.value[value] == true
                    else
                        isSelected = self.value == value
                    end

                    button.value = isSelected
                    if button.value then
                        tween.play(button.indicator, {
                            Size = UDim2.new(0, 2, 0, 6),
                            BackgroundTransparency = 0
                        }, { duration = 0.2 })

                        tween.play(button.indicator.ImageLabel, {
                            ImageTransparency = 0.92
                        }, { duration = 0.2 })

                        creator.addThemeObject(button.title, {
                            TextTransparency = "optionTextTransparency"
                        })

                        tween.play(button.title, {
                            TextTransparency = creator.getThemeProperty("optionTextTransparency")
                        })

                        creator.addThemeObject(button.frame, {
                            BackgroundTransparency = button.hovering and "optionHoverActiveTransparency" or "optionTransparency"
                        })

                        tween.play(button.frame, {
                            BackgroundTransparency = button.hovering and creator.getThemeProperty("optionHoverActiveTransparency") or creator.getThemeProperty("optionTransparency")
                        })
                    else
                        tween.play(button.indicator, {
                            Size = UDim2.new(0, 2, 0, 0),
                            BackgroundTransparency = 1
                        }, { duration = 0.2 })

                        tween.play(button.indicator.ImageLabel, {
                            ImageTransparency = 1
                        }, { duration = 0.2 })

                        creator.addThemeObject(button.title, {
                            TextTransparency = "optionTextNotActiveTransparency"
                        })

                        tween.play(button.title, {
                            TextTransparency = creator.getThemeProperty("optionTextNotActiveTransparency")
                        })

                        creator.addThemeObject(button.frame, {
                            BackgroundTransparency = button.hovering and "optionHoverTransparency" or "optionNotActiveTransparency"
                        })

                        tween.play(button.frame, {
                            BackgroundTransparency = button.hovering and creator.getThemeProperty("optionHoverTransparency") or creator.getThemeProperty("optionNotActiveTransparency")
                        })
                    end
				end
			end
		else
            self:build()
            self:setValue(self.value)
		end

		if self.multi then
            local selectedItems = {}
            for k, v in self.value do
                if table.find(self.options, k) and v == true then
                    table.insert(selectedItems, tostring(k))
                end
            end

            dropdownText.Text = #selectedItems > 0 and table.concat(selectedItems, ", ") or "None"
        else
            dropdownText.Text = tostring(self.value or "None")
        end
	end

    function dropdown:onChanged(func)
        dropdown.changed = func
        func(dropdown.value)
    end

	function dropdown:setValue(value)
	    if self.multi then
            local newValue = {}
            for _, option in self.options do
                newValue[option] = (value[option] and true) or (table.find(value, option) and true) or false
            end

            self.value = newValue
        else
            self.value = table.find(self.options, value) and value or self.value
        end

        self:updateValue()

	    library:safeCallback(dropdown.callback, value)
	    library:safeCallback(dropdown.changed, value)
	end

	function dropdown:destroy()
        if dropdown.opened then
            dropdown:close()
        end

        dropdownFrame:destroy()

        for _, button in self.buttons do
            if button.destroy then
                button:destroy()
            end
        end

        dropdownHolderCanvas:Destroy()
        library.options[flag] = nil
	end

	addSignal(dropdownDisplay.MouseEnter, function()
    	creator.addThemeObject(dropdownDisplay, {
            BackgroundTransparency = 'optionHoverActiveTransparency'
        })

        tween.play(dropdownDisplay, {
            BackgroundTransparency = creator.getThemeProperty('optionHoverActiveTransparency')
        }, { duration = 0.2 })
    end)

    addSignal(dropdownDisplay.MouseLeave, function()
    	creator.addThemeObject(dropdownDisplay, {
            BackgroundTransparency = 'optionTransparency'
        })

        tween.play(dropdownDisplay, {
            BackgroundTransparency = creator.getThemeProperty('optionTransparency')
        }, { duration = 0.2 })
    end)

    addSignal(dropdownButton.Activated, function()
        if dropdown.opened then
            return
        end

        dropdown:open()
    end)

    addSignal(userInputService.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local absPos, absSize = dropdownHolderFrame.AbsolutePosition, dropdownHolderFrame.AbsoluteSize
			if
				mouse.X < absPos.X
				or mouse.X > absPos.X + absSize.X
				or input.Position.Y < (absPos.Y - 20 - 1)
				or input.Position.Y > absPos.Y + absSize.Y
			then
				dropdown:close()
			end
		end
	end)

    dropdown:setValue(dropdown.value)

    library.options[flag] = dropdown
    return dropdown
end

return element
