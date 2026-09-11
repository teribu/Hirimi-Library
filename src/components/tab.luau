local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local tabModule = {
    library = nil,
    window = nil,
    sectionModule = nil,

    tabs = {},
    groups = {},
    layers = {},

    currentTab = nil,
    currentSection = nil,
    currentLayer = 1,

    totalTabs = 0,
    totalGroups = 0,
    setuped = false
}

function tabModule:newGroup(title, collapsible, parent)
    local window = tabModule.window

    self.totalGroups = self.totalGroups + 1

    local group = {
        name = title,
        index = self.totalGroups,
        collapsed = false
    }

    group.title = new("TextLabel", {
        Text = title,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 10,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Size = UDim2.new(1, 0, 0, 20),
        themeTag = {
            TextColor3 = "group",
            TextTransparency = "groupTransparency",
        }
    }, {
        new("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
        })
    })

    group.button = new("TextButton", {
        Text = '',
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        group.title,
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
        })
    })

    group.top = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        group.button,
    })

    group.containerListLayout = new("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    group.container = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    }, {
        group.containerListLayout,
    })

    group.root = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = group.index - 1,
        ClipsDescendants = true,
        Parent = parent,
    }, {
        group.top,
        group.container,
        new("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    if collapsible then
        group.title.Size = UDim2.new(1, -18, 0, 20)
        group.icon = new("ImageLabel", {
            Image = "rbxassetid://10709790948",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            Parent = group.button,
            themeTag = {
                ImageColor3 = "group",
                ImageTransparency = "groupTransparency"
            }
        })

        function group:setCollapsed(value)
            self.collapsed = not not value

            if self.collapsed then
                group.container.Size = UDim2.new(1, 0, 0, group.containerListLayout.AbsoluteContentSize.Y // window.scaler.Scale)
                group.container.AutomaticSize = Enum.AutomaticSize.None

                tween.plays(group, {
                    container = {
                        props = {
                            Size = UDim2.new(1, 0, 0, 0)
                        }
                    },
                    icon = {
                        props = {
                            Rotation = -90
                        }
                    }
                }, nil, { duration = 0.2 })
            else
                local targetHeight = group.containerListLayout.AbsoluteContentSize.Y // window.scaler.Scale

                tween.plays(group, {
                    container = {
                        props = {
                            Size = UDim2.new(1, 0, 0, targetHeight)
                        }
                    },
                    icon = {
                        props = {
                            Rotation = 0
                        }
                    }
                }, nil, { duration = 0.2 }, function()
                    group.container.AutomaticSize = Enum.AutomaticSize.Y
                end)
            end
        end

        group.button.Activated:Connect(function()
            group:setCollapsed(not group.collapsed)
        end)
    end

    function group:addTab(config)
        return tabModule:newTab(config.title, config.icon, self.container)
    end

    self.groups[group.index] = group
    return group
end

function tabModule:getLayer(layerIndex)
    local layer = self.layers[layerIndex]
    if layer then
        return layer
    end

    self.layers[layerIndex] = {
        totalChildren = 0,
        children = {},
        root = new("CanvasGroup", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            LayoutOrder = layerIndex,
            Parent = self.window.panel.container
        })
    }

    if layerIndex == 0 then
        self.layers[layerIndex].container = new("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollingEnabled = true,
            BackgroundTransparency = 1,
            ClipsDescendants = false,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = self.layers[layerIndex].root,
            themeTag = {
                ScrollBarImageColor3 = "scrollBarImage",
                ScrollBarImageTransparency = "scrollBarImageTransparency"
            }
        }, {
            new("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            new("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 0),
                PaddingBottom = UDim.new(0, 0)
            })
        })
    end

    return self.layers[layerIndex]
end

function tabModule:newTab(title, icon, parent)
    local library = tabModule.library
    local window = tabModule.window

    self.totalTabs = self.totalTabs + 1

    local tab = {
        selected = false,
        hoving = false,
        name = title,
        index = self.totalTabs,
        type = "tab",
        layer = 1
    }

    local trigger = {}
    tab.trigger = trigger

    trigger.title = new("TextLabel", {
        Text = title,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        TextSize = 10,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        themeTag = {
            TextColor3 = "secondary",
            TextTransparency = "secondaryTransparency"
        }
    })

    local checkedIcon = library:getIcon(icon) or icon
    if checkedIcon ~= "" and checkedIcon ~= nil then
        trigger.icon = new("ImageLabel", {
            Image = checkedIcon,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            themeTag = {
                ImageColor3 = "secondary",
                ImageTransparency = "secondaryTransparency"
            }
        })

        trigger.title.Position = UDim2.new(0, 17, 0, 0)
        trigger.title.Size = UDim2.new(1, -17, 0, 0)
    end

    trigger.frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 25),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = tab.index,
        themeTag = {
            BackgroundColor3 = "tab",
            BackgroundTransparency = "tabTransparency",
        }
    }, {
        trigger.title,
        trigger.icon,
        new("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 7),
            PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7),
            PaddingBottom = UDim.new(0, 7),
        })
    })

    trigger.indicatorFrame = new("Frame", {
        Size = UDim2.new(0, 2, 0, 0),
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

    trigger.indicator = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 2, 0, 8),
        BackgroundTransparency = 1
    }, {
        trigger.indicatorFrame
    })

    trigger.root = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = parent
    }, {
        trigger.frame,
        trigger.indicator
    })

    addSignal(trigger.root.MouseEnter, function()
        tab.hoving = true
        if tab.selected then
            creator.addThemeObject(trigger.frame, {
                BackgroundTransparency = "tabActiveHoverTransparency"
            })
            tween.play(trigger.frame, {
                BackgroundTransparency = creator.getThemeProperty("tabActiveHoverTransparency")
            })
        else
            creator.addThemeObject(trigger.frame, {
                BackgroundTransparency = "tabHoverTransparency"
            })
            tween.play(trigger.frame, {
                BackgroundTransparency = creator.getThemeProperty("tabHoverTransparency")
            })
        end
    end)

    addSignal(trigger.root.MouseLeave, function()
        tab.hoving = false
        if tab.selected then
            creator.addThemeObject(trigger.frame, {
                BackgroundTransparency = "tabActiveTransparency"
            })
            tween.play(trigger.frame, {
                BackgroundTransparency = creator.getThemeProperty("tabActiveTransparency")
            })
        else
            creator.addThemeObject(trigger.frame, {
                BackgroundTransparency = "tabTransparency"
            })
            tween.play(trigger.frame, {
                BackgroundTransparency = creator.getThemeProperty("tabTransparency")
            })
        end
    end)

    local container = {}
    tab.container = container

    container.container = new("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Size = UDim2.new(1, 0, 1, 0),
        LayoutOrder = tab.index,
        themeTag = {
            ScrollBarImageColor3 = "scrollBarImage",
            ScrollBarImageTransparency = "scrollBarImageTransparency"
        }
    }, {
        new("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0)
        })
    })

    if not self.setuped then
        self:getLayer(0)
    end

    container.root = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        Parent = self:getLayer(tab.layer).root
    }, {
        container.container
    })

    addSignal(trigger.root.Activated, function()
        tabModule:selectTab(tab)
    end)

    local elements = library.elements

    local function addSection(parent, config)
        local targetLayer = self:getLayer(parent.layer + 1)
        targetLayer.totalChildren = targetLayer.totalChildren + 1

        local section = self.sectionModule:newSection(
            config.title, config.desc,
            targetLayer.totalChildren,
            parent.layer + 1,
            parent, tab
        )

        function section:addSection(config)
            return addSection(self, config)
        end

        setmetatable(section, elements)
        return section
    end

    function tab:addSection(config)
        return addSection(self, config)
    end

    function tab:getPath()
        return {self}
    end

    self.tabs[tab.index] = tab

    if not self.setuped and self.window.panel.pageLayout and self.window.panel.pageLayout.CurrentPage.LayoutOrder == 0 then
        self.window.panel.pageLayout:JumpToIndex(1)
        self.setuped = true
    end

    local targetLayer = self:getLayer(tab.layer)
    targetLayer.totalChildren = targetLayer.totalChildren + 1
    targetLayer.children[tab.index] = tab

    setmetatable(tab, elements)
    return tab
end

function tabModule:selectTab(tab)
    if type(tab) == "number" then
        tab = self.tabs[tab]
    end

    if not tab or type(tab) ~= "table" then
        return
    end

    creator.addThemeObject(tab.trigger.frame, {
        BackgroundTransparency = if not tab.hoving then "tabActiveTransparency" else "tabActiveHoverTransparency"
    })

    creator.addThemeObject(tab.trigger.title, {
        TextColor3 = "primary",
        TextTransparency = "primaryTransparency"
    })

    creator.addThemeObject(tab.trigger.icon, {
        ImageColor3 = "primary",
        ImageTransparency = "primaryTransparency"
    })

    tween.plays(tab.trigger, {
        frame = {
            props = {
                BackgroundTransparency = if not tab.hoving
                    then creator.getThemeProperty("tabActiveTransparency")
                    else creator.getThemeProperty("tabActiveHoverTransparency")
            }
        },
        title = {
            props = {
                TextColor3 = creator.getThemeProperty("primary"),
                TextTransparency = creator.getThemeProperty("primaryTransparency")
            }
        },
        icon = {
            props = {
                ImageColor3 = creator.getThemeProperty("primary"),
                ImageTransparency = creator.getThemeProperty("primaryTransparency")
            }
        }
    }, { duration = 0.3 })

    tab.trigger.indicatorFrame.AnchorPoint = Vector2.new(0, 0)
    tab.trigger.indicatorFrame.Position = UDim2.new(0, 0, 0, 0)

    if self.currentTab then
        self.currentTab.container.root.GroupTransparency = 1
        self.currentTab.container.root.Visible = false

        if self.currentTab ~= tab then
            tab.container.container.CanvasPosition = Vector2.new(0, 0)

            creator.addThemeObject(self.currentTab.trigger.frame, {
                BackgroundTransparency = if not self.currentTab.hoving then "tabTransparency" else "tabHoverTransparency"
            })

            creator.addThemeObject(self.currentTab.trigger.title, {
                TextColor3 = "secondary",
                TextTransparency = "secondaryTransparency"
            })

            creator.addThemeObject(self.currentTab.trigger.icon, {
                ImageColor3 = "secondary",
                ImageTransparency = "secondaryTransparency"
            })

            tween.plays(self.currentTab.trigger, {
                frame = {
                    props = {
                        BackgroundTransparency = creator.getThemeProperty(if not self.currentTab.hoving then "tabTransparency" else "tabHoverTransparency")
                    }
                },
                title = {
                    props = {
                        TextColor3 = creator.getThemeProperty("secondary"),
                        TextTransparency = creator.getThemeProperty("secondaryTransparency")
                    }
                },
                icon = {
                    props = {
                        ImageColor3 = creator.getThemeProperty("secondary"),
                        ImageTransparency = creator.getThemeProperty("secondaryTransparency")
                    }
                },
            }, { duration = 0.4 })

            self.currentTab.selected = false
        end

        self.currentTab.trigger.indicatorFrame.AnchorPoint = Vector2.new(0, 1)
        self.currentTab.trigger.indicatorFrame.Position = UDim2.new(0, 0, 1, 0)

        if self.currentTab.index > tab.index then
            tab.trigger.indicatorFrame.AnchorPoint = Vector2.new(0, 1)
            tab.trigger.indicatorFrame.Position = UDim2.new(0, 0, 1, 0)

            self.currentTab.trigger.indicatorFrame.AnchorPoint = Vector2.new(0, 0)
            self.currentTab.trigger.indicatorFrame.Position = UDim2.new(0, 0, 0, 0)
        end

        tween.play(self.currentTab.trigger.indicatorFrame, {
            Size = UDim2.new(0, 2, 0, 0),
            BackgroundTransparency = 1
        }, { duration = 0.3 })

        tween.play(self.currentTab.trigger.indicatorFrame.ImageLabel, {
            ImageTransparency = 1
        }, { duration = 0.3 })
    end

    tween.play(tab.trigger.indicatorFrame, {
        Size = UDim2.new(0, 2, 0, 8),
        BackgroundTransparency = 0
    }, { duration = 0.3 })

    tween.play(tab.trigger.indicatorFrame.ImageLabel, {
        ImageTransparency = 0.9
    }, { duration = 0.3 })

    tab.container.root.Visible = true

    if self.currentLayer == tab.layer then
        tab.container.container.CanvasPosition = Vector2.new(0, 0)
        tab.container.root.Position = UDim2.new(0, 0, 0, 20)

        tween.play(tab.container.root, {
            Position = UDim2.new(0, 0, 0, 0),
        }, { duration = 0.3, easingStyle = "Quad" })

        tween.play(tab.container.root, {
            GroupTransparency = 0
        }, { duration = 0.4, easingStyle = "Quad" })
    else
        tab.container.root.GroupTransparency = 0
    end

    self.currentTab = tab
    tab.selected = true

    self.currentLayer = tab.layer
    self.currentSection = nil

    if self.window.panel.pageLayout then
        self.window.panel.pageLayout:JumpToIndex(tab.layer)
    end

    if self.window.panel.updateHeader then
        self.window.panel:updateHeader({tab})
    end

    return tab
end

function tabModule:setSection(section)
    local layer = self:getLayer(section.layer)

    if not layer then
        return
    end

    if section.type == "tab" then
        return
    end

    for index, value in layer.children do
        if index ~= section.index then
            value.root.GroupTransparency = 1
            value.root.Visible = false
        end
    end

    section.root.GroupTransparency = 0
    section.root.Visible = true

    self.currentSection = section
end

function tabModule:navigateTo(section)
    if not section then
        return
    end

    if section.layer == 0 then
        return
    end

    if section.type == "tab" then
        return self:selectTab(section)
    end

    if self.currentTab ~= section.tab then
        self:selectTab(section.tab)
    end

    self:setSection(section)

    if self.currentLayer ~= section.layer then
        self.currentLayer = section.layer

        if self.window.panel.pageLayout then
            self.window.panel.pageLayout:JumpToIndex(section.layer)
        end
    end

    if self.window.panel then
        self.window.panel:updateHeader(section:getPath())
    end

    return section
end

function tabModule:init(library, window)
    self.library = library
    self.window = window

    self.sectionModule = require("./section"):init(self, library)
    return self
end

return tabModule
