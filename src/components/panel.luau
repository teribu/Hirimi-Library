local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

return function (parent, window, tabModule)
	local panel = {
		activeSection = nil,
		sectionInstances = {}
	}

	panel.header = new("ScrollingFrame", {
    	AutomaticCanvasSize = Enum.AutomaticSize.X,
    	CanvasSize = UDim2.new(0, 0, 0, 0),
    	ScrollBarImageTransparency = 1,
    	ScrollBarThickness = 0,
    	ScrollingDirection = Enum.ScrollingDirection.X,
    	ScrollingEnabled = true,
    	BackgroundTransparency = 1,
    	ClipsDescendants = true,
    	Size = UDim2.new(1, 0, 0, 50)
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			FillDirection = Enum.FillDirection.Horizontal
		}),
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 15),
			PaddingBottom = UDim.new(0, 15)
		})
	})

	local TweenService = game:GetService("TweenService")


	addSignal(panel.header.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        local maxX = math.max(0, panel.header.UIListLayout.AbsoluteContentSize.X - panel.header.AbsoluteSize.X)

        local targetPos = Vector2.new(maxX * window.scaler.Scale, 0)

        tween.play(panel.header,
            { CanvasPosition = targetPos },
            { duration = 0.2, easingStyle = Enum.EasingStyle.Quad }
        )
	end)

	panel.pageLayout = new("UIPageLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		EasingStyle = Enum.EasingStyle.Exponential,
		EasingDirection = Enum.EasingDirection.Out,
		TweenTime = 0.4,
		GamepadInputEnabled = false,
		ScrollWheelInputEnabled = false,
		TouchInputEnabled = false
	})

	panel.container = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 1, - 50),
		ClipsDescendants = true
	}, {
		panel.pageLayout,
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 12)
		})
	})

	panel.root = new("Frame", {
		Position = UDim2.new(0, window.tabWidth, 0, 0),
		Size = UDim2.new(1, - window.tabWidth, 1, 0),
		Parent = parent,
		themeTag = {
			BackgroundColor = "panel",
			BackgroundTransparency = "panelTransparency"
		}
	}, {
		panel.header,
		panel.container
	})

	function panel:clear()
    	for layer, sectionInstance in panel.sectionInstances do
    		if layer > panel.activeSection then
    			creator.removeThemeObject(sectionInstance.button, {
    				TextTransparency = "headerTransparency"
    			})

    			tween.play(sectionInstance.button, {
    				TextTransparency = 1
    			}, { duration = 0.25 }, function()
    				sectionInstance.root.Visible = false
    			end)

    			if sectionInstance.icon then
    				creator.removeThemeObject(sectionInstance.icon, {
    					ImageColor3 = "headerActive",
    					ImageTransparency = "headerActiveTransparency"
    				})

    				tween.play(sectionInstance.icon, {
    					ImageTransparency = 1
    				}, { duration = 0.25 }, function()
    					sectionInstance.iconHolder.Visible = false
    				end)
    			end

                sectionInstance.root.Size = UDim2.new(0, sectionInstance.root.AbsoluteSize.X // window.scaler.Scale, 1, 0)
                sectionInstance.root.AutomaticSize = Enum.AutomaticSize.None

                tween.play(sectionInstance.root,
                    { Size = UDim2.new(0, 0, 1, 0) },
                    { duration = 0.2, easingStyle = Enum.EasingStyle.Quad })
    		end
    	end
	end

	function panel:updateHeader(path)
		for layer, item in path or {} do
			local section = item
            local sectionInstance = panel.sectionInstances[layer]

			if not sectionInstance then
				sectionInstance = {
					section = section
				}
				panel.sectionInstances[layer] = sectionInstance

				sectionInstance.button = new("TextButton", {
				    Text = section.name,
					FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					TextSize = 10,
					TextTransparency = 0.5,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(0, 0, 1, 0),
					themeTag = {
						TextColor3 = "header",
						TextTransparency = "headerTransparency"
					}
				})

				sectionInstance.root = new("Frame", {
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					LayoutOrder = section.layer,
					Size = UDim2.new(0, 0, 1, 0),
					Parent = panel.header
				}, {
					sectionInstance.button,
					new("UIListLayout", {
						Padding = UDim.new(0, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						FillDirection = Enum.FillDirection.Horizontal
					})
				})

				if section.type == "section" then
					sectionInstance.icon = new("ImageLabel", {
						Image = "rbxassetid://10709791437",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(0, 12, 0, 12),
						themeTag = {
							ImageColor3 = "header",
							ImageTransparency = "headerTransparency"
						}
					})

					sectionInstance.iconHolder = new("Frame", {
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0, 20),
						Parent = sectionInstance.root
					}, {
						sectionInstance.icon,
						new("UIPadding", {
							PaddingLeft = UDim.new(0, 0),
							PaddingRight = UDim.new(0, 4),
							PaddingTop = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 4),
						})
					})
				end

				local function getPath(parent, path)
				    table.insert(path, 1, parent)

                    if parent.type == "tab" then
                        return path
                    end

                    return getPath(parent.parent, path)
                end

                function sectionInstance:getPath()
                    return getPath(self.section.parent, {self.section})
                end

                function sectionInstance:update(section)
                    self.section = section
                    self.button.Text = section.name
                end

				addSignal(sectionInstance.button.Activated, function()
					tabModule:navigateTo(sectionInstance.section)
				end)
			else
				sectionInstance:update(section)
			end

			sectionInstance.root.Visible = true
			sectionInstance.root.AutomaticSize = Enum.AutomaticSize.X

			if sectionInstance.iconHolder then
				sectionInstance.iconHolder.Visible = true
			end

			if layer == #path then
				creator.addThemeObject(sectionInstance.button, {
					TextColor3 = "headerActive",
					TextTransparency = "headerActiveTransparency"
				})

				tween.play(sectionInstance.button, {
					TextColor3 = creator.getThemeProperty("headerActive"),
					TextTransparency = creator.getThemeProperty("headerActiveTransparency")
				})

				if section.type == "section" then
					creator.addThemeObject(sectionInstance.icon, {
						ImageColor3 = "header",
						ImageTransparency = "headerTransparency"
					})

					tween.play(sectionInstance.icon, {
						ImageColor3 = creator.getThemeProperty("header"),
						ImageTransparency = creator.getThemeProperty("headerTransparency")
					})
				end

				panel.activeSection = layer
			else
				creator.addThemeObject(sectionInstance.button, {
					TextColor3 = "header",
					TextTransparency = "headerTransparency"
				})

				tween.play(sectionInstance.button, {
					TextColor3 = creator.getThemeProperty("header"),
					TextTransparency = creator.getThemeProperty("headerTransparency")
				})

				if section.type == "section" then
					creator.addThemeObject(sectionInstance.icon, {
						ImageColor3 = "header",
						ImageTransparency = "headerTransparency"
					})

					tween.play(sectionInstance.icon, {
						ImageColor3 = creator.getThemeProperty("header"),
						ImageTransparency = creator.getThemeProperty("headerTransparency")
					})
				end
			end
		end

		panel:clear()
	end

	return panel
end
