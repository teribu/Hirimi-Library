local themeManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/themeManager.luau"))()
local saveManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/saveManager.luau"))()
local library = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/releases/latest/download/main.luau"))()

local window = library:createWindow({
    title = "Hirimi Library",
    logo = "rbxassetid://109103782993270",
    sidebar = {
        width = 146,
        searchBar = {
            placeholderText = "Quick Search...",
            realTime = true,
            clearTextOnFocus = true
        },
        userProfile = {
            name = "Teru",
            desc = "# 3107"
        }
    },
    size = {
        responsive = false,
        dragSizeable = true,
        scale = 0.75,
        realtimeResize = true
    },
    theme = "light",
    acrylic = true,
    keybind = Enum.KeyCode.LeftControl
})

local groups = {
    main = window:addGroup({
        title = "Main Section",
        collapsible = false,
    }),
    features = window:addGroup({
        title = "Features",
        collapsible = true,
    }),
}

local tabs = {
    home = groups.main:addTab({
        title = "Home",
        icon = "rbxassetid://10723407389",
    }),
    options = groups.main:addTab({
        title = "Options",
        icon = "rbxassetid://10734950020",
    }),
    attacking = groups.features:addTab({
        title = "Attacking",
        icon = "rbxassetid://10734975692",
    }),
    defending = groups.features:addTab({
        title = "Defending",
        icon = "rbxassetid://10734951847",
    }),
}

do
    local home_direct_toggle = tabs.home:addToggle("home_direct_toggle", {
        title = "Direct Home Toggle",
        desc = "Element placed directly in tab.",
        value = true,
    })
    home_direct_toggle:onChanged(function(v)
        print("[ Hirimi: home_direct_toggle ] " .. tostring(v))
    end)

    local home_direct_slider = tabs.home:addSlider("home_direct_slider", {
        title = "Direct Home Slider",
        desc = "Element placed directly in tab.",
        min = 1,
        max = 100,
        step = 1,
        value = 50,
    })
    home_direct_slider:onChanged(function(v)
        print("[ Hirimi: home_direct_slider ] " .. tostring(v))
    end)

    local home_direct_button = tabs.home:addButton({
        title = "Direct Home Button",
        callback = function()
            print("[ Hirimi: Direct Home Button ] Executed")
        end
    })

    local home_direct_input = tabs.home:addInput("home_direct_input", {
        title = "Direct Home Input",
        desc = "Element placed directly in tab.",
        placeHolder = "Type...",
        value = "HomeData",
    })
    home_direct_input:onChanged(function(v)
        print("[ Hirimi: home_direct_input ] " .. tostring(v))
    end)

    local home_direct_dropdown = tabs.home:addDropdown("home_direct_dropdown", {
        title = "Direct Home Dropdown",
        desc = "Select option",
        options = {"Opt1", "Opt2", "Opt3", "Opt4", "Opt5", "Opt6", "Opt7", "Opt8", "Opt9", "Opt10", "Opt11", "Opt12", "Opt13", "Opt14", "Opt15", "Opt16", "Opt17", "Opt18", "Opt19", "Opt20"},
        value = "Opt1",
    })
    home_direct_dropdown:onChanged(function(v)
        print("[ Hirimi: home_direct_dropdown ] " .. tostring(v))
    end)

    local home_direct_multidropdown = tabs.home:addDropdown("home_direct_multidropdown", {
        title = "Direct Home Multi Dropdown",
        desc = "Select multiple options",
        options = {"Opt1", "Opt2", "Opt3", "Opt4", "Opt5", "Opt6", "Opt7", "Opt8", "Opt9", "Opt10", "Opt11", "Opt12", "Opt13", "Opt14", "Opt15", "Opt16", "Opt17", "Opt18", "Opt19", "Opt20"},
        value = {"Opt1", "Opt2", "Opt3"},
        multi = true,
    })
    home_direct_multidropdown:onChanged(function(v)
        print("[ Hirimi: home_direct_multidropdown ] Selected count: " .. tostring(#v))
    end)

    local n1 = tabs.home:addSection({
        title = "Level 1: Core System",
        desc = "Base layer of nested architecture.",
    })

    local nest_t1 = n1:addToggle("nest_t1", {
        title = "Toggle Layer 1",
        desc = "State trigger",
        value = true,
    })
    nest_t1:onChanged(function(v)
        print("[ Hirimi: nest_t1 ] " .. tostring(v))
    end)

    local nest_s1 = n1:addSlider("nest_s1", {
        title = "Slider Layer 1",
        desc = "Value scale",
        min = 1,
        max = 10,
        step = 1,
        value = 5,
    })
    nest_s1:onChanged(function(v)
        print("[ Hirimi: nest_s1 ] " .. tostring(v))
    end)

    local nest_i1 = n1:addInput("nest_i1", {
        title = "Input Layer 1",
        desc = "Text config",
        placeHolder = "Text...",
        value = "Data1",
    })
    nest_i1:onChanged(function(v)
        print("[ Hirimi: nest_i1 ] " .. tostring(v))
    end)

    local nest_d1 = n1:addDropdown("nest_d1", {
        title = "Dropdown Layer 1",
        desc = "Select option",
        options = {"A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "A11", "A12", "A13", "A14", "A15", "A16", "A17", "A18", "A19", "A20"},
        value = "A1",
    })
    nest_d1:onChanged(function(v)
        print("[ Hirimi: nest_d1 ] " .. tostring(v))
    end)

    local n2 = n1:addSection({
        title = "Level 2: Sub-System",
        desc = "Second nested tier.",
    })

    local nest_t2 = n2:addToggle("nest_t2", {
        title = "Toggle Layer 2",
        desc = "State trigger",
        value = true,
    })
    nest_t2:onChanged(function(v)
        print("[ Hirimi: nest_t2 ] " .. tostring(v))
    end)

    local nest_s2 = n2:addSlider("nest_s2", {
        title = "Slider Layer 2",
        desc = "Value scale",
        min = 1,
        max = 10,
        step = 1,
        value = 5,
    })
    nest_s2:onChanged(function(v)
        print("[ Hirimi: nest_s2 ] " .. tostring(v))
    end)

    local nest_i2 = n2:addInput("nest_i2", {
        title = "Input Layer 2",
        desc = "Text config",
        placeHolder = "Text...",
        value = "Data2",
    })
    nest_i2:onChanged(function(v)
        print("[ Hirimi: nest_i2 ] " .. tostring(v))
    end)

    local nest_d2 = n2:addDropdown("nest_d2", {
        title = "Dropdown Layer 2",
        desc = "Select option",
        options = {"B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10", "B11", "B12", "B13", "B14", "B15", "B16", "B17", "B18", "B19", "B20"},
        value = "B1",
    })
    nest_d2:onChanged(function(v)
        print("[ Hirimi: nest_d2 ] " .. tostring(v))
    end)

    local n3 = n2:addSection({
        title = "Level 3: Intermediate Matrix",
        desc = "Third nested tier.",
    })

    local nest_t3 = n3:addToggle("nest_t3", {
        title = "Toggle Layer 3",
        desc = "State trigger",
        value = true,
    })
    nest_t3:onChanged(function(v)
        print("[ Hirimi: nest_t3 ] " .. tostring(v))
    end)

    local nest_s3 = n3:addSlider("nest_s3", {
        title = "Slider Layer 3",
        desc = "Value scale",
        min = 1,
        max = 10,
        step = 1,
        value = 5,
    })
    nest_s3:onChanged(function(v)
        print("[ Hirimi: nest_s3 ] " .. tostring(v))
    end)

    local nest_i3 = n3:addInput("nest_i3", {
        title = "Input Layer 3",
        desc = "Text config",
        placeHolder = "Text...",
        value = "Data3",
    })
    nest_i3:onChanged(function(v)
        print("[ Hirimi: nest_i3 ] " .. tostring(v))
    end)

    local nest_d3 = n3:addDropdown("nest_d3", {
        title = "Dropdown Layer 3",
        desc = "Select option",
        options = {"C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20"},
        value = "C1",
    })
    nest_d3:onChanged(function(v)
        print("[ Hirimi: nest_d3 ] " .. tostring(v))
    end)

    local n4 = n3:addSection({
        title = "Level 4: Advanced Routing",
        desc = "Fourth nested tier.",
    })

    local nest_t4 = n4:addToggle("nest_t4", {
        title = "Toggle Layer 4",
        desc = "State trigger",
        value = true,
    })
    nest_t4:onChanged(function(v)
        print("[ Hirimi: nest_t4 ] " .. tostring(v))
    end)

    local nest_s4 = n4:addSlider("nest_s4", {
        title = "Slider Layer 4",
        desc = "Value scale",
        min = 1,
        max = 10,
        step = 1,
        value = 5,
    })
    nest_s4:onChanged(function(v)
        print("[ Hirimi: nest_s4 ] " .. tostring(v))
    end)

    local nest_i4 = n4:addInput("nest_i4", {
        title = "Input Layer 4",
        desc = "Text config",
        placeHolder = "Text...",
        value = "Data4",
    })
    nest_i4:onChanged(function(v)
        print("[ Hirimi: nest_i4 ] " .. tostring(v))
    end)

    local nest_d4 = n4:addDropdown("nest_d4", {
        title = "Dropdown Layer 4",
        desc = "Select option",
        options = {"D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "D9", "D10", "D11", "D12", "D13", "D14", "D15", "D16", "D17", "D18", "D19", "D20"},
        value = "D1",
    })
    nest_d4:onChanged(function(v)
        print("[ Hirimi: nest_d4 ] " .. tostring(v))
    end)

    local n5 = n4:addSection({
        title = "Level 5: Deep Terminal",
        desc = "Fifth nested tier.",
    })

    local nest_t5 = n5:addToggle("nest_t5", {
        title = "Toggle Layer 5",
        desc = "State trigger",
        value = true,
    })
    nest_t5:onChanged(function(v)
        print("[ Hirimi: nest_t5 ] " .. tostring(v))
    end)

    local nest_s5 = n5:addSlider("nest_s5", {
        title = "Slider Layer 5",
        desc = "Value scale",
        min = 1,
        max = 10,
        step = 1,
        value = 5,
    })
    nest_s5:onChanged(function(v)
        print("[ Hirimi: nest_s5 ] " .. tostring(v))
    end)

    local nest_i5 = n5:addInput("nest_i5", {
        title = "Input Layer 5",
        desc = "Text config",
        placeHolder = "Text...",
        value = "Data5",
    })
    nest_i5:onChanged(function(v)
        print("[ Hirimi: nest_i5 ] " .. tostring(v))
    end)

    local nest_d5 = n5:addDropdown("nest_d5", {
        title = "Multi Dropdown Layer 5",
        desc = "Select multiple options",
        options = {"E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10", "E11", "E12", "E13", "E14", "E15", "E16", "E17", "E18", "E19", "E20"},
        value = {"E1", "E2", "E3"},
        multi = true,
    })
    nest_d5:onChanged(function(v)
        print("[ Hirimi: nest_d5 ] Selected count: " .. tostring(#v))
    end)
end

do
    local themes = tabs.options:addDropdown("themes", {
        title = "UI Theme",
        desc = "Select your preferred interface color scheme.",
        options = library:getThemes(),
        value = library.theme,
    })
    themes:onChanged(function(v)
        library:setTheme(v)
    end)

    local acrylic = tabs.options:addToggle("acrylic", {
        title = "Acrylic Blur",
        desc = "Apply semi-transparent blur behind the interface.",
        value = true,
    })
    acrylic:onChanged(function(v)
        window:setAcrylic(v)
    end)

    local transparent = tabs.options:addToggle("transparent", {
        title = "Transparent UI",
        desc = "Make the window background transparent to see through.",
        value = true,
    })
    transparent:onChanged(function(v)
        window:setTransparent(v)
    end)
end

do
    local atk_toggle = tabs.attacking:addToggle("atk_toggle", {
        title = "Enable Auto-Target",
        desc = "Activate targeting logic.",
        value = false,
    })
    atk_toggle:onChanged(function(v)
        print("[ Hirimi: atk_toggle ] " .. tostring(v))
    end)

    local atk_slider = tabs.attacking:addSlider("atk_slider", {
        title = "Aim Interpolation",
        desc = "Smoothness scale.",
        min = 1,
        max = 20,
        step = 1,
        value = 5,
    })
    atk_slider:onChanged(function(v)
        print("[ Hirimi: atk_slider ] " .. tostring(v))
    end)

    local atk_input = tabs.attacking:addInput("atk_input", {
        title = "Target Key",
        desc = "Key to hold.",
        placeHolder = "MouseButton2",
        value = "MouseButton2",
    })
    atk_input:onChanged(function(v)
        print("[ Hirimi: atk_input ] " .. tostring(v))
    end)

    local atk_dropdown = tabs.attacking:addDropdown("atk_dropdown", {
        title = "Target Priority",
        desc = "Sorting method.",
        options = {"Pr1", "Pr2", "Pr3", "Pr4", "Pr5", "Pr6", "Pr7", "Pr8", "Pr9", "Pr10", "Pr11", "Pr12", "Pr13", "Pr14", "Pr15", "Pr16", "Pr17", "Pr18", "Pr19", "Pr20"},
        value = "Pr1",
    })
    atk_dropdown:onChanged(function(v)
        print("[ Hirimi: atk_dropdown ] " .. tostring(v))
    end)

    local atk_multidropdown = tabs.attacking:addDropdown("atk_multidropdown", {
        title = "Ignored Factions",
        desc = "Filter out entities.",
        options = {"Fac1", "Fac2", "Fac3", "Fac4", "Fac5", "Fac6", "Fac7", "Fac8", "Fac9", "Fac10", "Fac11", "Fac12", "Fac13", "Fac14", "Fac15", "Fac16", "Fac17", "Fac18", "Fac19", "Fac20"},
        value = {"Fac1", "Fac2"},
        multi = true,
    })
    atk_multidropdown:onChanged(function(v)
        print("[ Hirimi: atk_multidropdown ] Selected count: " .. tostring(#v))
    end)
end

do
    local def_toggle = tabs.defending:addToggle("def_toggle", {
        title = "Auto Use Consumables",
        desc = "Consume healing items.",
        value = true,
    })
    def_toggle:onChanged(function(v)
        print("[ Hirimi: def_toggle ] " .. tostring(v))
    end)

    local def_slider = tabs.defending:addSlider("def_slider", {
        title = "Health Threshold",
        desc = "Trigger percentage.",
        min = 10,
        max = 80,
        step = 5,
        value = 35,
        suffix = "%",
    })
    def_slider:onChanged(function(v)
        print("[ Hirimi: def_slider ] " .. tostring(v))
    end)

    local def_input = tabs.defending:addInput("def_input", {
        title = "Safe Anchor Coordinates",
        desc = "Vector3 fallback destination.",
        placeHolder = "0, 50, 0",
        value = "120, 15, -450",
    })
    def_input:onChanged(function(v)
        print("[ Hirimi: def_input ] " .. tostring(v))
    end)

    local def_dropdown = tabs.defending:addDropdown("def_dropdown", {
        title = "Combat Stance",
        desc = "Choose defensive posture.",
        options = {"St1", "St2", "St3", "St4", "St5", "St6", "St7", "St8", "St9", "St10", "St11", "St12", "St13", "St14", "St15", "St16", "St17", "St18", "St19", "St20"},
        value = "St1",
    })
    def_dropdown:onChanged(function(v)
        print("[ Hirimi: def_dropdown ] " .. tostring(v))
    end)

    local def_multidropdown = tabs.defending:addDropdown("def_multidropdown", {
        title = "Safety Protocols",
        desc = "Select safety overrides.",
        options = {"Prot1", "Prot2", "Prot3", "Prot4", "Prot5", "Prot6", "Prot7", "Prot8", "Prot9", "Prot10", "Prot11", "Prot12", "Prot13", "Prot14", "Prot15", "Prot16", "Prot17", "Prot18", "Prot19", "Prot20"},
        value = {"Prot1", "Prot2"},
        multi = true,
    })
    def_multidropdown:onChanged(function(v)
        print("[ Hirimi: def_multidropdown ] Selected count: " .. tostring(#v))
    end)
end

task.wait(1)

library:notify({
    title = "Hi, " .. tostring(game:GetService("Players").LocalPlayer.Name),
    desc = "Welcome to Hirimi Library!",
    duration = 5,
})

themeManager:init(library)
saveManager:init(library)
