local creator = require("../modules/creator")
local tween = creator.tween

local new = creator.new
local addSignal = creator.addSignal

local sectionModule = {
    tabModule = nil,
    library = nil
}

function sectionModule:newSection(title, desc, index, layer, parent, tab)
    local library = self.library
    local section = {
        type = "section",
        name = title,
        index = index,
        layer = layer,
        parent = parent,
        tab = tab,
        totalSections = 0
    }

    local sectionFrame = require("./element")(title, desc,
        if parent.type == "section" then
            self.tabModule:getLayer(section.parent.layer).children[section.parent.index].container
        else
            tab.container.container
    , true)

    sectionFrame.labelHolder.Size = UDim2.new(1, -50, 0, 0)

    function section:setTitle(title)
        return sectionFrame:setTitle(title)
    end

    function section:setDescription(desc)
        return sectionFrame:setDescription(desc)
    end

    local sectionIcon = new("ImageLabel", {
        Image = "rbxassetid://10709791437",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Parent = sectionFrame.root,
        themeTag = {
            ImageColor3 = "secondary",
            ImageTransparency = "secondaryTransparency",
        }
    })

    section.container = new("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        Active = true,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Size = UDim2.new(1, 0, 1, 0),
        LayoutOrder = section.index,
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

    section.root = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        Parent = self.tabModule:getLayer(section.layer).root
    }, {
        section.container
    })

    local function getPath(parent, path)
        table.insert(path, 1, parent)

        if parent.type == "tab" then
            return path
        end

        return getPath(parent.parent, path)
    end

    function section:getPath()
        return getPath(self.parent, {self})
    end

    local currentSection = section
    addSignal(sectionFrame.root.Activated, function()
        self.tabModule:navigateTo(currentSection)
    end)

    self.tabModule:getLayer(section.layer).children[section.index] = section

    section.rootFrame = sectionFrame.root
    library.options[library:generateUniqueId()] = section
    return section
end

function sectionModule:init(tabModule, library)
    self.tabModule = tabModule
    self.library = library

    return self
end

return sectionModule
