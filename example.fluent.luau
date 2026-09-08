local libraryRaw = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/releases/latest/download/main.luau"))()
local themeManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/themeManager.luau"))()
local saveManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/saveManager.luau"))()
local fluentAdapterFactory = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/fluentAdapter.luau"))

local Fluent = fluentAdapterFactory(libraryRaw)

local Window = Fluent:CreateWindow({
    Title = "Hirimi Library",
    Logo = "rbxassetid://109103782993270",
    TabWidth = 160,
    Theme = "Dark",
    Acrylic = true,
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "rbxassetid://10723407389" }),
    Options = Window:AddTab({ Title = "Options", Icon = "rbxassetid://10734950020" }),
    Attacking = Window:AddTab({ Title = "Attacking", Icon = "rbxassetid://10734975692" }),
    Defending = Window:AddTab({ Title = "Defending", Icon = "rbxassetid://10734951847" })
}

do
    local home_direct_toggle = Tabs.Home:AddToggle("home_direct_toggle", {
        Title = "Direct Home Toggle",
        Description = "Element placed directly in tab.",
        Default = true
    })
    home_direct_toggle:OnChanged(function(v)
        print("[ Hirimi: home_direct_toggle ] " .. tostring(v))
    end)

    local home_direct_slider = Tabs.Home:AddSlider("home_direct_slider", {
        Title = "Direct Home Slider",
        Description = "Element placed directly in tab.",
        Min = 1,
        Max = 100,
        Rounding = 1,
        Default = 50
    })
    home_direct_slider:OnChanged(function(v)
        print("[ Hirimi: home_direct_slider ] " .. tostring(v))
    end)

    Tabs.Home:AddButton({
        Title = "Direct Home Button",
        Description = "Click to execute",
        Callback = function()
            print("[ Hirimi: Direct Home Button ] Executed")
        end
    })

    local home_direct_input = Tabs.Home:AddInput({
        Title = "Direct Home Input",
        Description = "Element placed directly in tab.",
        Placeholder = "Type..."
    })
    home_direct_input:OnChanged(function(v)
        print("[ Hirimi: home_direct_input ] " .. tostring(v))
    end)

    local home_direct_dropdown = Tabs.Home:AddDropdown("home_direct_dropdown", {
        Title = "Direct Home Dropdown",
        Description = "Select option",
        Values = {"Opt1", "Opt2", "Opt3", "Opt4", "Opt5", "Opt6", "Opt7", "Opt8", "Opt9", "Opt10"},
        Default = "Opt1"
    })
    home_direct_dropdown:OnChanged(function(v)
        print("[ Hirimi: home_direct_dropdown ] " .. tostring(v))
    end)

    local home_direct_multidropdown = Tabs.Home:AddDropdown("home_direct_multidropdown", {
        Title = "Direct Home Multi Dropdown",
        Description = "Select multiple options",
        Values = {"Opt1", "Opt2", "Opt3", "Opt4", "Opt5", "Opt6", "Opt7", "Opt8", "Opt9", "Opt10"},
        Default = {"Opt1", "Opt2", "Opt3"},
        Multi = true
    })
    home_direct_multidropdown:OnChanged(function(v)
        print("[ Hirimi: home_direct_multidropdown ] Selected updated")
    end)

    Tabs.Home:AddParagraph({
        Title = "Level 1: Core System",
        Content = "Base layer of nested architecture."
    })

    local nest_t1 = Tabs.Home:AddToggle("nest_t1", {
        Title = "Toggle Layer 1",
        Description = "State trigger",
        Default = true
    })
    nest_t1:OnChanged(function(v)
        print("[ Hirimi: nest_t1 ] " .. tostring(v))
    end)

    local nest_s1 = Tabs.Home:AddSlider("nest_s1", {
        Title = "Slider Layer 1",
        Description = "Value scale",
        Min = 1,
        Max = 10,
        Rounding = 1,
        Default = 5
    })
    nest_s1:OnChanged(function(v)
        print("[ Hirimi: nest_s1 ] " .. tostring(v))
    end)
end

do
    local opt_toggle = Tabs.Options:AddToggle("opt_toggle", {
        Title = "Smooth Transitions",
        Description = "Enable animations.",
        Default = true
    })
    opt_toggle:OnChanged(function(v)
        print("[ Hirimi: opt_toggle ] " .. tostring(v))
    end)

    local opt_slider = Tabs.Options:AddSlider("opt_slider", {
        Title = "Refresh Rate Cap",
        Description = "Limit FPS.",
        Min = 30,
        Max = 144,
        Rounding = 1,
        Default = 60
    })
    opt_slider:OnChanged(function(v)
        print("[ Hirimi: opt_slider ] " .. tostring(v))
    end)

    Tabs.Options:AddButton({
        Title = "Reset Preferences",
        Description = "Reset all settings to default",
        Callback = function()
            print("[ Hirimi: Reset Preferences ] Executed")
        end
    })

    local opt_input = Tabs.Options:AddInput({
        Title = "Hotkey Configuration",
        Description = "Enter key string.",
        Placeholder = "LeftControl"
    })
    opt_input:OnChanged(function(v)
        print("[ Hirimi: opt_input ] " .. tostring(v))
    end)

    local opt_dropdown = Tabs.Options:AddDropdown("opt_dropdown", {
        Title = "Accent Color Scheme",
        Description = "Select theme accent.",
        Values = {"Col1", "Col2", "Col3", "Col4", "Col5"},
        Default = "Col1"
    })
    opt_dropdown:OnChanged(function(v)
        print("[ Hirimi: opt_dropdown ] " .. tostring(v))
    end)
end

do
    local atk_toggle = Tabs.Attacking:AddToggle("atk_toggle", {
        Title = "Enable Auto-Target",
        Description = "Activate targeting logic.",
        Default = false
    })
    atk_toggle:OnChanged(function(v)
        print("[ Hirimi: atk_toggle ] " .. tostring(v))
    end)

    local atk_slider = Tabs.Attacking:AddSlider("atk_slider", {
        Title = "Aim Interpolation",
        Description = "Smoothness scale.",
        Min = 1,
        Max = 20,
        Rounding = 1,
        Default = 5
    })
    atk_slider:OnChanged(function(v)
        print("[ Hirimi: atk_slider ] " .. tostring(v))
    end)

    Tabs.Attacking:AddButton({
        Title = "Calibrate Hitboxes",
        Description = "Recalculate target hitboxes",
        Callback = function()
            print("[ Hirimi: Calibrate Hitboxes ] Executed")
        end
    })

    local atk_input = Tabs.Attacking:AddInput({
        Title = "Target Key",
        Description = "Key to hold.",
        Placeholder = "MouseButton2"
    })
    atk_input:OnChanged(function(v)
        print("[ Hirimi: atk_input ] " .. tostring(v))
    end)
end

do
    local def_toggle = Tabs.Defending:AddToggle("def_toggle", {
        Title = "Auto Use Consumables",
        Description = "Consume healing items.",
        Default = true
    })
    def_toggle:OnChanged(function(v)
        print("[ Hirimi: def_toggle ] " .. tostring(v))
    end)

    local def_slider = Tabs.Defending:AddSlider("def_slider", {
        Title = "Health Threshold",
        Description = "Trigger percentage.",
        Min = 10,
        Max = 80,
        Rounding = 5,
        Default = 35
    })
    def_slider:OnChanged(function(v)
        print("[ Hirimi: def_slider ] " .. tostring(v))
    end)

    Tabs.Defending:AddButton({
        Title = "Emergency Warp",
        Description = "Teleport to safety",
        Callback = function()
            print("[ Hirimi: Emergency Warp ] Executed")
        end
    })
end

task.wait(1)

Fluent:Notify({
    Title = "Hi, " .. tostring(game:GetService("Players").LocalPlayer.Name),
    Content = "Welcome to Hirimi Library!",
    Duration = 5
})

themeManager:init(library)
saveManager:init(library)
