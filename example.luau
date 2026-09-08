local themeManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/themeManager.luau"))()
local saveManager = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/raw/main/addons/saveManager.luau"))()
local library = loadstring(game:HttpGet("https://github.com/teribu/Hirimi-Library/releases/latest/download/main.luau"))()

local window = library:createWindow({
    title = "Hirimi Library",
    logo = "rbxassetid://109103782993270",
    sidebar = {
        width = 160,
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
        realtimeResize = true -- default is true, recommended false for performance
    },
    theme = "dark",
    acrylic = true, -- default is true, recommended false for performance
    keybind = Enum.KeyCode.LeftControl,
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
    local secWelcome = tabs.home:addSection({
        title = "System Dashboard",
        desc = "Overview of runtime statistics and quick profile diagnostics.",
    })

    secWelcome:addParagraph({
        title = "Hirimi Framework v2.4",
        desc = "All core modules loaded successfully. Environment is stable and ready for execution.",
    })

    secWelcome:addToggle("sys_telemetry", {
        title = "Live Telemetry Tracking",
        desc = "Stream real-time performance metrics to the internal console.",
        value = true,
    })

    secWelcome:addSlider("sys_framerate", {
        title = "UI Refresh Cap",
        desc = "Limit interface redraw rate to conserve GPU cycles.",
        min = 30,
        max = 144,
        step = 1,
        value = 60,
        suffix = " FPS",
    })

    local secQuickLaunch = tabs.home:addSection({
        title = "Quick Actions",
        desc = "Frequently used utility triggers.",
    })

    secQuickLaunch:addButton({
        title = "Clear Cache & Memory",
        callback = function()
            print("[Hirimi]: Memory cache flushed successfully.")
        end,
    })

    secQuickLaunch:addButton({
        title = "Copy Diagnostic Report",
        callback = function()
            print("[Hirimi]: Diagnostics copied to clipboard.")
        end,
    })
end

do
    local secTheme = tabs.options:addSection({
        title = "Visual & Theme",
        desc = "Customize appearance, colors, and layout aesthetics.",
    })

    secTheme:addDropdown("opt_accent", {
        title = "Accent Color",
        desc = "Select the primary UI highlight scheme.",
        options = {"Cyber Blue", "Neon Emerald", "Sunset Orange", "Amethyst Purple"},
        value = "Cyber Blue",
    })

    secTheme:addToggle("opt_animations", {
        title = "UI Smooth Transitions",
        desc = "Enable tweening and easing effects on window interactions.",
        value = true,
    })

    local secHotkeys = tabs.options:addSection({
        title = "Keybindings",
        desc = "Manage shortcut triggers for quick panels.",
    })

    secHotkeys:addInput("opt_toggle_key", {
        title = "Menu Toggle Key",
        desc = "Keycode string used to show/hide the main interface.",
        placeHolder = "LeftControl",
        value = "LeftControl",
    })
end

do
    local secCombat = tabs.attacking:addSection({
        title = "Aimbot & Targeting",
        desc = "Configure automated target acquisition and locking parameters.",
    })

    secCombat:addToggle("atk_enabled", {
        title = "Enable Auto-Target",
        desc = "Aimbot logic activates when holding designated key.",
        value = false,
    })

    secCombat:addDropdown("atk_priority", {
        title = "Target Priority",
        desc = "Determine how entities are sorted for engagement.",
        options = {"Closest Distance", "Lowest Health", "Crosshair Proximity"},
        value = "Closest Distance",
    })

    secCombat:addSlider("atk_smoothness", {
        title = "Aim Interpolation",
        desc = "Lower values snap instantly; higher values look human-like.",
        min = 1,
        max = 20,
        step = 1,
        value = 5,
    })

    local currentNested = tabs.attacking:addSection({
        title = "Phase 1: Initial Engagement",
        desc = "Core detection boundaries and initial target line-of-sight checks.",
    })

    currentNested:addToggle("nested_p1_active", {
        title = "Enable Engagement Filter",
        desc = "Filter out targets obscured by environmental geometry.",
        value = true,
    })

    currentNested = currentNested:addSection({
        title = "Phase 2: Melee Strike Vector",
        desc = "Calculate optimal hitboxes and swing projection angles.",
    })

    currentNested:addSlider("nested_p2_angle", {
        title = "Strike Cone Angle",
        desc = "Maximum directional deviation allowed for impact registration.",
        min = 15,
        max = 90,
        step = 5,
        value = 45,
        suffix = "°",
    })

    currentNested = currentNested:addSection({
        title = "Phase 3: Timing Window Adjustment",
        desc = "Sync attack execution frames with network latency compensation.",
    })

    currentNested:addInput("nested_p3_offset", {
        title = "Latency Offset",
        desc = "Milliseconds delay compensation for packet jitter.",
        placeHolder = "50",
        value = "35",
    })

    currentNested = currentNested:addSection({
        title = "Phase 4: Post-Hit Recovery",
        desc = "Manage animation cancel windows and recovery frames.",
    })

    currentNested:addToggle("nested_p4_cancel", {
        title = "Auto Animation Cancel",
        desc = "Instantly abort recovery frames upon successful impact.",
        value = true,
    })

    currentNested = currentNested:addSection({
        title = "Phase 5: Combo Loop Override",
        desc = "Force continuous chain execution without manual reset.",
    })

    currentNested:addSlider("nested_p5_repeats", {
        title = "Max Loop Count",
        desc = "Number of consecutive automated chain cycles.",
        min = 1,
        max = 10,
        step = 1,
        value = 3,
    })
end

do
    local secDefense = tabs.defending:addSection({
        title = "Automated Survival",
        desc = "Health monitoring and emergency mitigation triggers.",
    })

    secDefense:addToggle("def_autoheal", {
        title = "Auto Use Consumables",
        desc = "Instantly consume healing items when health drops.",
        value = true,
    })

    secDefense:addSlider("def_threshold", {
        title = "Health Threshold",
        desc = "Trigger defensive routines when HP falls below this ratio.",
        min = 10,
        max = 80,
        step = 5,
        value = 35,
        suffix = "%",
    })

    local secSafeZone = tabs.defending:addSection({
        title = "Evasion & Positioning",
        desc = "Configure automated escape paths and safe-spot anchors.",
    })

    secSafeZone:addToggle("def_autododge", {
        title = "Smart Evasion",
        desc = "Automatically step out of incoming projectile vectors.",
        value = false,
    })

    secSafeZone:addInput("def_anchor", {
        title = "Safe Anchor Coordinates",
        desc = "Preset vector3 fallback coordinates for emergency teleport.",
        placeHolder = "0, 50, 0",
        value = "120, 15, -450",
    })
end

wait(1)

library:notify({
    title = "Hi, " .. tostring(game:GetService("Players").LocalPlayer.Name),
    desc = "Welcome to Hirimi Library!",
    duration = 5,
})

themeManager:init(library)
saveManager:init(library)
