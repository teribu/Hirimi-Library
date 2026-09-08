local themes = {}

for _, theme in script:GetChildren() do
    local required = require(theme)
    themes[required.name] = required
end

return themes
