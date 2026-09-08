local creator = require("../modules/creator")
local tween = require("../modules/tween")

local new = creator.new
local addSignal = creator.addSignal

local element = {}
element.__index = element
element.__type = "Paragraph"

function element:new(config)
    assert(config.title, "paragraph - missing title")

    local library = self.library
    local paragraph = {
        type = "paragraph",
        name = config.title,
        parent = self.parent
    }

    local paragraphFrame = require("../components/element")(config.title, config.desc, self.container, false)
    paragraphFrame.labelHolder.Size = UDim2.new(1, 0, 0, 0)

    function paragraph:setTitle(text)
        return paragraphFrame:setTitle(text)
    end

    function paragraph:setDescription(text)
        return paragraphFrame:setDescription(text)
    end

    function paragraph:destroy()
        return paragraphFrame:destroy()
    end

    if library then
        library.options[library:generateUniqueId()] = paragraph
    end
    return paragraph
end

return element
