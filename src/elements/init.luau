local elements = {}

for _, element in script:GetChildren() do
    local required = require(element)
    elements[required.__type] = required
end

return elements
