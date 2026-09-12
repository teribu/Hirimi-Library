return function (library)
    local fluentAdapter = {
        Name = library.name,
        Version = library.version,
        Window = library.window,
        Options = library.options,
        Themes = library.themes,
        Theme = library.theme,
        GUI = library.gui
    }

    function fluentAdapter:Notify(config)
        return library:notify({
            title = config.Title,
            desc = config.Content,
            duration = config.Duration
        })
    end

    function fluentAdapter:CreateWindow(config)
        local window = library:createWindow({
            title = config.Title,
            logo = config.Logo,
            sidebar = config.Sidebar,
            size = {
                responsive = false,
                dragSizeable = true,
                scale = 0.75,
                size = config.Size,
                realtimeResize = true
            },
            theme = config.Theme,
            acrylic = config.Acrylic,
            keybind = config.MinimizeKey
        })

        function window:AddTab(config)
            local tab = window:addTab({
                title = config.Title,
                icon = config.Icon
            })

            function tab:AddParagraph(config)
                return tab:addParagraph({
                    title = config.Title,
                    desc = config.Content
                })
            end

            function tab:AddButton(config)
                return tab:addButton({
                    title = config.Title,
                    desc = config.Description,
                    callback = config.Callback
                })
            end

            function tab:AddToggle(flag, config)
                local toggle = tab:addToggle(flag, {
                    title = config.Title,
                    desc = config.Description,
                    value = config.Default,
                    callback = config.Callback
                })

                toggle.OnChanged = toggle.onChanged
                toggle.Value = toggle.value

                function toggle:SetValue(value)
                    toggle:setValue(value)
                    toggle.Value = toggle.value
                end

                return toggle
            end

            function tab:AddSlider(flag, config)
                local slider = tab:addSlider(flag, {
                    title = config.Title,
                    desc = config.Description,
                    value = config.Default,
                    min = config.Min,
                    max = config.Max,
                    step = config.Rounding,
                    realTime = if config.Finished == nil then false else not config.Finished,
                    callback = config.Callback
                })

                slider.OnChanged = slider.onChanged
                slider.Value = slider.value

                function slider:SetValue(value)
                    slider:setValue(value)
                    slider.Value = slider.value
                end

                return slider
            end

            function tab:AddDropdown(flag, config)
                local dropdown = tab:addDropdown(flag, {
                    title = config.Title,
                    desc = config.Description,
                    value = config.Default,
                    options = config.Values,
                    multi = config.Multi,
                    callback = config.Callback
                })

                dropdown.OnChanged = dropdown.onChanged
                dropdown.Value = dropdown.value
                dropdown.Options = dropdown.options

                function dropdown:SetValue(value)
                    dropdown:setValue(value)
                    dropdown.Value = dropdown.value
                end

                function dropdown:SetOptions(options)
                    dropdown:setOptions(options)
                    dropdown.Options = dropdown.options
                end

                return dropdown
            end

            function tab:AddInput(flag, config)
                local input = tab:addInput(flag, {
                    title = config.Title,
                    desc = config.Description,
                    placeHolder = config.Placeholder,
                    numeric = config.Numeric,
                    realTime = if config.Finished == nil then false else not config.Finished,
                    callback = config.Callback
                })

                input.OnChanged = input.onChanged
                input.Value = input.value

                function input:SetValue(value)
                    input:setValue(value)
                    input.Value = input.value
                end

                return input
            end

            return tab
        end
        return window
    end

    return fluentAdapter
end
