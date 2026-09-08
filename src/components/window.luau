local userInputService = game:GetService("UserInputService")
local camera = game:GetService("Workspace").CurrentCamera

local tween = require("../modules/tween")
local creator = require("../modules/creator")
local new = creator.new
local addSignal = creator.addSignal

return function (config)
    local library = config.library
    local window = {
        state = false,
        keybind = config.keybind,
        scale = config.size.scale,
        responsive = config.size.responsive,
        realtimeResize = config.size.realtimeResize,
        tabWidth = config.sidebar.width or 160
    }

    window.scaler = new("UIScale", {
        Scale = 1,
    })

    window.root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = config.parent,
        themeTag = {
            BackgroundColor3 = "background",
            BackgroundTransparency = "backgroundTransparency"
        },
    }, {
        window.scaler,
        new("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        new("UIShadow", {
            BlurRadius = UDim.new(0, 20),
            themeTag = {
                Color = "shadow",
                Transparency = "shadowTransparency"
            }
        })
    })

    local tabModule = require("./tab"):init(library, window)

    window.panel = require("./panel")(window.root, window, tabModule)
    window.sidebar = require("./sidebar")({
        title = config.title,
        logo = config.logo,
        library = library,
        window = window,
        searchBar = config.sidebar.searchBar,
        tabModule = tabModule,
        userProfile = config.sidebar.userProfile,
        parent = window.root
    })

    function window:addTab(tabConfig)
        return tabModule:newTab(tabConfig.title, tabConfig.icon, self.sidebar.tabContainer.tabHolder)
    end

    function window:addGroup(groupConfig)
        return tabModule:newGroup(groupConfig.title, groupConfig.collapsible, self.sidebar.tabContainer.tabHolder)
    end

    function window:selectTab(tab)
        return tabModule:selectTab(tab)
    end

    local function updateScale()
        if not window.responsive then return end

        local currentSize = window.root.AbsoluteSize
        if currentSize.X == 0 or currentSize.Y == 0 then return end

        local base = currentSize / window.scaler.Scale
        local maxAllowed = camera.ViewportSize * window.scale

        window.scaler.Scale = math.min(maxAllowed.X / base.X, maxAllowed.Y / base.Y)
    end

    local oldResponsive = window.responsive
    window.responsive = true
    updateScale()
    window.responsive = oldResponsive
    addSignal(camera:GetPropertyChangedSignal("ViewportSize"), updateScale)

    function window:setScale(scale)
        self.scale = scale
        updateScale()
    end

    local sizeDragger
    if config.size.dragSizeable then
        if window.realtimeResize then
            local sizing, posInput, sizStart
            local minSizeX, minSizeY = 500, 300

            sizeDragger = new('TextButton', {
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 20, 1, 20),
                Size = UDim2.fromOffset(40, 40),
                Name = 'sizeDragger',
                Parent = window.root,
                ZIndex = 1e6
            })

            local function updateSize(input)
                local Delta = input.Position - posInput

                local currentScale = window.scaler.Scale
                local scaledDeltaX = Delta.X / currentScale
                local scaledDeltaY = Delta.Y / currentScale

                window.root.Size = UDim2.fromOffset(
                    math.max(sizStart.X.Offset + scaledDeltaX, minSizeX),
                    math.max(sizStart.Y.Offset + scaledDeltaY, minSizeY)
                )
            end

            addSignal(sizeDragger.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sizing = true

                    if not changed then
                        changed = true
                        local pos = window.root.Position
                        local size = window.root.AbsoluteSize

                        window.root.Position = UDim2.new(
                            pos.X.Scale,
                            pos.X.Offset - size.X * 0.5,

                            pos.Y.Scale,
                            pos.Y.Offset - size.Y * 0.5
                        )

                        window.root.AnchorPoint = Vector2.zero
                    end

                    posInput, sizStart = input.Position, window.root.Size

                    local disconnectChanged, disconnectEnded

                    disconnectChanged = userInputService.InputChanged:Connect(function(moveInput)
                        if sizing and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                            updateSize(moveInput)
                        end
                    end)

                    disconnectEnded = userInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == input.UserInputType then
                            sizing = false
                            disconnectChanged:Disconnect()
                            disconnectEnded:Disconnect()
                        end
                    end)
                end
            end)
        else
            local ghostDraggingBorder = new("UIStroke", {
                Thickness = 1,
                Transparency = 1,
                themeTag = {
                    Color = "ghostDraggingBorder"
                }
            })

            local ghostDragging = new("Frame", {
                Size = window.root.Size,
                BackgroundTransparency = 1,
                Parent = window.root,
                themeTag = {
                    BackgroundColor3 = "ghostDragging"
                }
            }, {
                ghostDraggingBorder,
                new("UICorner", {
                    CornerRadius = UDim.new(0, 8)
                })
            })

            local ghostDraggingIcon
            if config.logo then
                ghostDraggingIcon = new("ImageLabel", {
                    Image = config.logo,
                    Size = UDim2.fromOffset(50, 50),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Parent = ghostDragging,
                    ImageTransparency = 1,
                    ImageColor3 = Color3.new(1, 1, 1)
                }, {
                    new("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    new("UIShadow", {
                        BlurRadius = UDim.new(0, 20),
                        Transparency = 1,
                        themeTag = {
                            Color = "shadow"
                        }
                    })
                })
            end

            local sizing, posInput, sizStart
            local minSizeX, minSizeY = 500, 300

            sizeDragger = new('TextButton', {
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 20, 1, 20),
                Size = UDim2.fromOffset(40, 40),
                Name = 'sizeDragger',
                Parent = ghostDragging,
                ZIndex = 1e6
            })

            local function updateSize(input)
                local Delta = input.Position - posInput

                local currentScale = window.scaler.Scale
                local scaledDeltaX = Delta.X / currentScale
                local scaledDeltaY = Delta.Y / currentScale

                ghostDragging.Size = UDim2.fromOffset(
                    math.max(sizStart.X.Offset + scaledDeltaX, minSizeX),
                    math.max(sizStart.Y.Offset + scaledDeltaY, minSizeY)
                )
            end

            addSignal(sizeDragger.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sizing = true
                    creator.addThemeObject(ghostDragging, {
                        BackgroundTransparency = "ghostDraggingTransparency"
                    })
                    creator.addThemeObject(ghostDraggingBorder, {
                        Transparency = "ghostDraggingBorderTransparency"
                    })

                    ghostDragging.BackgroundTransparency = creator.getThemeProperty("ghostDraggingTransparency")
                    ghostDraggingBorder.Transparency = creator.getThemeProperty("ghostDraggingBorderTransparency")

                    if config.logo then
                        ghostDraggingIcon.ImageTransparency = 0
                        creator.addThemeObject(ghostDraggingIcon.UIShadow, {
                            Transparency = "shadowTransparency"
                        })

                        ghostDraggingIcon.UIShadow.Transparency = creator.getThemeProperty("shadowTransparency")
                    end

                    if not changed then
                        changed = true
                        local pos = window.root.Position
                        local size = window.root.AbsoluteSize

                        window.root.Position = UDim2.new(
                            pos.X.Scale,
                            pos.X.Offset - size.X * 0.5,

                            pos.Y.Scale,
                            pos.Y.Offset - size.Y * 0.5
                        )

                        window.root.AnchorPoint = Vector2.zero
                    end

                    posInput, sizStart = input.Position, window.root.Size

                    local disconnectChanged, disconnectEnded

                    disconnectChanged = userInputService.InputChanged:Connect(function(moveInput)
                        if sizing and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                            updateSize(moveInput)
                        end
                    end)

                    disconnectEnded = userInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == input.UserInputType then
                            window.root.Size = ghostDragging.Size

                            creator.removeThemeObject(ghostDragging, {
                                BackgroundTransparency = "ghostDraggingTransparency"
                            })
                            creator.removeThemeObject(ghostDraggingBorder, {
                                Transparency = "ghostDraggingBorderTransparency"
                            })

                            ghostDragging.BackgroundTransparency = 1
                            ghostDraggingBorder.Transparency = 1
                            if config.logo then
                                ghostDraggingIcon.ImageTransparency = 1
                                creator.removeThemeObject(ghostDraggingIcon.UIShadow, {
                                    Transparency = "shadowTransparency"
                                })

                                ghostDraggingIcon.UIShadow.Transparency = 1
                            end

                            sizing = false
                            disconnectChanged:Disconnect()
                            disconnectEnded:Disconnect()
                        end
                    end)
                end
            end)
        end
    end

    function window:setResponsive(responsive)
        self.responsive = not not responsive
        if sizeDragger then
            sizeDragger.Visible = not self.responsive
        end
    end

    window.acrylic = require("./acrylic")
    window.acrylic:apply(window.root)

    function window:setAcrylic(value)
        return self.acrylic:setValue(value)
    end

    function window:setVisibility(visible)
        self.state = not not visible
        self.root.Visible = visible

        if not visible then
            library:notify({
                title = "Hirimi",
                desc = "Use ".. tostring(window.keybind) .. " to open the GUI again.",
                duration = 5,
            })
        end
    end

    addSignal(game:GetService("UserInputService").InputBegan, function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == window.keybind then
            window:setVisibility(not window.root.Visible)
        end
    end)

    window:setVisibility(true)
    return window
end
