local userInputService = game:GetService("UserInputService")

local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

return function (config)
    local library = config.library
    local window = config.window

    local sidebar = {}

    sidebar.root = new("Frame", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, window.tabWidth, 1, 0),
        Parent = config.parent,
        themeTag = {
            BackgroundColor3 = "sidebar",
            BackgroundTransparency = "sidebarTransparency"
        }
    }, {
        new("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        new("UICorner", {
            TopLeftRadius = UDim.new(0, 8),
            BottomLeftRadius = UDim.new(0, 8),
            BottomRightRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
        })
    })

    local titleBar = {}
    sidebar.titleBar = titleBar

    titleBar.title = new("TextLabel", {
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Text = config.title,
        LayoutOrder = 1,
        themeTag = {
            TextColor3 = "titleBar",
            TextTransparency = "titleBarTransparency"
        }
    })

    titleBar.root = new("Frame", {
        BackgroundTransparency = 1,
        Parent = sidebar.root,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        titleBar.title,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 0),
        }),

        new("UIListLayout", {
            Padding = UDim.new(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal
        })
    })

    if config.logo and config.logo ~= "" then
        titleBar.logo = new("ImageLabel", {
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundTransparency = 1,
            Image = config.logo,
            Parent = titleBar.root
        }, {
            new("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })
    end

    local dragging, dragInput, dragStart, startPos
    local function updatePostion(input)
        local delta = input.Position - dragStart
        local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        tween.play(
            window.root,
            { Position = pos },
            { duration = 0.2, easingStyle = "Quad" }
        ):Play()
    end

    addSignal(titleBar.root.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.root.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    addSignal(titleBar.root.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    addSignal(userInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            updatePostion(input)
        end
    end)

    local containerSize = 50

    local tabModule = config.tabModule
    local button = require("../elements/button")
    if config.searchBar then
        local searchBar = {
            type = "searchBar",
            value = "",
            realtime = if config.searchBar.realtime == nil then true else config.searchBar.realtime,
            results = {},
            buttons = {}
        }

        sidebar.searchBar = searchBar
        window.searchBar = searchBar

        searchBar.icon = new("ImageLabel", {
            Image = "rbxassetid://10734943674",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 7, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            themeTag = {
                ImageColor3 = "searchIcon",
                ImageTransparency = "searchIconTransparency"
            }
        })

        searchBar.searchBox = new("TextBox", {
            BackgroundTransparency = 1,
            CursorPosition = -1,
            Position = UDim2.new(0, 24, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            PlaceholderText = config.searchBar.placeholderText or "Quick Search...",
            Text = "",
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            RichText = true,
            ClearTextOnFocus = if config.searchBar.clearTextOnFocus == nil then true else config.searchBar.clearTextOnFocus,
            themeTag = {
                TextColor3 = "searchBoxText",
                PlaceholderColor3 = "searchBoxPlaceholder"
            }
        })

        searchBar.frame = new("Frame", {
            Size = UDim2.new(1, 0, 0, 25),
            themeTag = {
                BackgroundColor3 = "searchBar",
                BackgroundTransparency = "searchBarTransparency"
            }
        }, {
            searchBar.searchBox,
            searchBar.icon,
            new("UICorner", {
                CornerRadius = UDim.new(0, 5)
            })
        })

        searchBar.root = new("Frame", {
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = sidebar.root
        }, {
            searchBar.frame,
            new("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 0),
                PaddingBottom = UDim.new(0, 10),
            })
        })

        function searchBar:search(text)
            local results = {}
            local cleanedSearchText = string.lower(text):gsub("%s+", "")
            if text == "" then
                return results
            end

            for value, item in library.options do
                if type(value) == "string" then
                    local cleanedValue = string.lower(value):gsub("%s+", "")
                    if string.find(cleanedValue, cleanedSearchText) then
                        results[item.name] = item
                    end
                end
                local cleanedName = string.lower(item.name):gsub("%s+", "")
                if string.find(cleanedName, cleanedSearchText) then
                    results[item.name] = item
                end
            end

            return results
        end

        function searchBar:expandPath(path)
            local expanded = {}
            for _, item in path do
                table.insert(expanded, item.name)
            end
            return table.concat(expanded, " > ")
        end

        function searchBar:build()
            for _, button in self.buttons do
                if button.destroy then
                    button:destroy()
                end
            end

            self.buttons = {}

            for value, item in self.results do
                self.buttons[value] = button.new({
                    container = tabModule:getLayer(0).container,
                }, {
                    title = value,
                    desc = "Found in " .. self:expandPath(item.parent:getPath()),
                    callback = function()
                        tabModule:navigateTo(item.parent)
                    end
                })
            end
        end

        function searchBar:update(text)
            if text == "" then
                if tabModule.currentTab or tabModule.currentSection then
                    tabModule:navigateTo(tabModule.currentTab or tabModule.currentSection)
                else
                    window.panel:updateHeader({
                        {
                            name = "",
                            layer = 0
                        }
                    })

                    if window.panel.pageLayout then
                        window.panel.pageLayout:JumpToIndex(0)
                    end
                end
            else
                if window.panel then
                    window.panel:updateHeader({
                        {
                            name = "Search Results",
                            layer = 0
                        }
                    })

                    if window.panel.pageLayout then
                        window.panel.pageLayout:JumpToIndex(0)
                    end
                end
            end

            searchBar.results = searchBar:search(text)
            searchBar:build()
        end

        addSignal(searchBar.searchBox:GetPropertyChangedSignal("Text"), function()
            if searchBar.realtime then
                searchBar:update(searchBar.searchBox.Text)
            end
        end)

        addSignal(searchBar.searchBox.FocusLost, function()
            if not searchBar.realtime then
                searchBar:update(searchBar.searchBox.Text)
            end
        end)

        containerSize += 35
    end

    if config.userProfile then
        local userProfile = {}
        sidebar.userProfile = userProfile

        userProfile.avatar = new("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            themeTag = {
                BackgroundColor3 = "userProfile",
                BackgroundTransparency = "userImageTransparency"
            }
        }, {
            new("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }),
            new("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Image = config.userProfile.avatar or "rbxassetid://80239799213490",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, {
                new("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
            })
        })

        userProfile.name = new("TextLabel", {
            Text = config.userProfile.name,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(1, 0, 0, 0),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            themeTag = {
                TextColor3 = "username",
                TextTransparency = "usernameTransparency"
            }
        })

        userProfile.labelHolder = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 28, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, {
            userProfile.name,
            new("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
        })

        if config.userProfile.desc then
            userProfile.description = new("TextLabel", {
                Text = config.userProfile.desc,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Size = UDim2.new(1, 0, 0, 0),
                TextSize = 8,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                Parent = userProfile.labelHolder,
                themeTag = {
                    TextColor3 = "userDescription",
                    TextTransparency = "userDescriptionTransparency"
                }
            })
        end

        userProfile.frame = new("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            themeTag = {
                BackgroundColor3 = "userProfile",
                BackgroundTransparency = "userProfileTransparency"
            }
        }, {
            userProfile.avatar,
            userProfile.labelHolder,
            new("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            }),
            new("UICorner", {
                CornerRadius = UDim.new(0, 7)
            })
        })

        userProfile.root = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            LayoutOrder = 3,
            Parent = sidebar.root
        }, {
            userProfile.frame,
            new("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            })
        })

        containerSize += 50
    end

    local tabContainer = {}
    sidebar.tabContainer = tabContainer

    tabContainer.tabHolder = new("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = false
    }, {
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
        }),

        new("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    tabContainer.root = new("Frame", {
        Size = UDim2.new(1, 0, 1, -containerSize),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = 2,
        Parent = sidebar.root
    }, {
        tabContainer.tabHolder
    })

    return sidebar
end
