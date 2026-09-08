local tweenService = game:GetService("TweenService")
local creator = require("./creator")
local addSignal = creator.addSignal

local tween = {
    presets = require("./presets"),
    infoCache = {},
    runningTweens = {}
}

function tween.parseEnum(enumType, value)
    if typeof(value) == "EnumItem" then return value end
    if type(value) == "string" then
        local success, result = pcall(function() return Enum[enumType][value] end)
        if success then return result end
    end
    return tween.presets.default[enumType]
end

function tween.getTweenInfo(preset)
    local def = tween.presets.default
    local current = type(preset) == "table" and preset or type(preset) == "string" and tween.presets[preset] or def

    local duration = tonumber(current.duration) or def.duration
    local easingStyle = tween.parseEnum("EasingStyle", current.easingStyle or def.easingStyle)
    local easingDirection = tween.parseEnum("EasingDirection", current.easingDirection or def.easingDirection)

    if not tween.infoCache[duration] then tween.infoCache[duration] = {} end
    if not tween.infoCache[duration][easingStyle] then tween.infoCache[duration][easingStyle] = {} end
    if not tween.infoCache[duration][easingStyle][easingDirection] then
        tween.infoCache[duration][easingStyle][easingDirection] = TweenInfo.new(duration, easingStyle, easingDirection)
    end

    return tween.infoCache[duration][easingStyle][easingDirection]
end

function tween.getTransparencyProperty(object)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then return "TextTransparency" end
    if object:IsA("ImageLabel") or object:IsA("ImageButton") then return "ImageTransparency" end
    if object:IsA("UIStroke") or object:IsA("UIGradient") or object:IsA("UIShadow") then return "Transparency" end
    return "BackgroundTransparency"
end

function tween.play(object, props, preset, callback)
    local formattedProps = {}

    for prop, value in props do
        local success = pcall(function() return object[prop] end)

        if success then
            if prop == "Transparency" then
                formattedProps[tween.getTransparencyProperty(object)] = value
            else
                formattedProps[prop] = value
            end
        else
            warn("[ Tween Error ] " .. object.Name .. " not have property " .. prop)
        end
    end

    if next(formattedProps) == nil then return nil end

    if tween.runningTweens[object] and tween.runningTweens[object].props == formattedProps then
        tween.runningTweens[object].tween:Cancel()
    end

    local tweenObject = tweenService:Create(object, tween.getTweenInfo(preset), formattedProps)

    tween.runningTweens[object] = {
        tween = tweenObject,
        props = formattedProps
    }

    local connection

    connection = addSignal(tweenObject.Completed, function(playbackState)
        connection:Disconnect()

        if tween.runningTweens[object] and tween.runningTweens[object].tween == tweenObject then
            tween.runningTweens[object] = nil
        end

        if callback and type(callback) == "function" and playbackState == Enum.PlaybackState.Completed then
            callback(playbackState)
        end
    end)

    tweenObject:Play()

    return tweenObject
end

function tween._applyRecursive(target, structure, props, preset, callback, tweens)
    for key, value in structure do
        if key == "props" or key == "preset" or key == "callback" or key == "delay" or key == "condition" then
            continue
        end

        local target = type(value) == "string" and ((target.FindFirstChild and target:FindFirstChild(key)) or target[value])
            or type(key) == "string" and (target.FindFirstChild and target:FindFirstChild(key) or target[key])
            or type(key) == "number" and target

        local props = value.props or props
        local preset = value.preset or preset
        local callback = value.callback or callback

        if target then
            task.delay(value.delay or 0, function()
                if value.condition and type(value.condition) == "function" and not value.condition() then return end
                table.insert(tweens, tween.play(target, props, preset, callback))
            end)
        end

        if type(key) == "string" and type(value) == "table" then
            tween._applyRecursive(target, value, props, preset, callback, tweens)
        end
    end
end

function tween.plays(target, structure, props, preset, callback)
    local tweens = {}

    if typeof(target) == "Instance" or type(target) == "table" then
        tween._applyRecursive(target, structure, props, preset, callback, tweens)
    end

    return {
        tweens = tweens,
        pause = function(self)
            for _, value in self.tweens do
                value:Pause()
            end
        end,
        cancel = function(self)
            for _, value in self.tweens do
                value:Cancel()
            end
        end,
    }
end

return tween
