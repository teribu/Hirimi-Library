local lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")

local acrylic = {
    blurSize = Vector2.new(10, 10),
    partSize = 0.01,
    partTransparency = 1 - 1e-7,
    intensity = 1,

    parts = {},
    objects = {},
    applied = {},
    blur = nil,
    connection = false,
}

acrylic.__index = acrylic

function acrylic.rayPlaneIntersect(planePos, planeNormal, rayOrigin, rayDirection)
    local v = rayOrigin - planePos
    local num = planeNormal:Dot(v)
    local den = planeNormal:Dot(rayDirection)
    local a = -num / den

    return rayOrigin + a * rayDirection
end

function acrylic.rebuild()
    table.clear(acrylic.parts)

    for _, part in acrylic.objects do
        acrylic.parts[#acrylic.parts + 1] = part
    end
end

function acrylic.updateObject(object)
    local frame = object.frame
    local part = object.part
    local mesh = object.mesh

    if not frame.Visible then
        part.Transparency = 1
        return
    end

    local camera = workspace.CurrentCamera

    part.Transparency = acrylic.partTransparency

    local corner0 = frame.AbsolutePosition + acrylic.blurSize
    local corner1 = corner0 + frame.AbsoluteSize - acrylic.blurSize * 2

    local ray0
    local ray1

    if object.ignoreInset then
        ray0 = camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
        ray1 = camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
    else
        ray0 = camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
        ray1 = camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
    end

    local planeOrigin =
        camera.CFrame.Position +
        camera.CFrame.LookVector * (0.05 - camera.NearPlaneZ)

    local planeNormal = camera.CFrame.LookVector

    local pos0 = acrylic.rayPlaneIntersect(
        planeOrigin,
        planeNormal,
        ray0.Origin,
        ray0.Direction
    )

    local pos1 = acrylic.rayPlaneIntersect(
        planeOrigin,
        planeNormal,
        ray1.Origin,
        ray1.Direction
    )

    pos0 = camera.CFrame:PointToObjectSpace(pos0)
    pos1 = camera.CFrame:PointToObjectSpace(pos1)

    local size = pos1 - pos0

    mesh.Offset = (pos0 + pos1) / 2
    mesh.Scale = size / acrylic.partSize
end

function acrylic.update()
    if not acrylic.blur then
        return
    end

    local camera = workspace.CurrentCamera

    acrylic.blur.NearIntensity = acrylic.intensity

    for object in acrylic.objects do
        acrylic.updateObject(object)
    end

    if #acrylic.parts > 0 then
        workspace:BulkMoveTo(
            acrylic.parts,
            table.create(#acrylic.parts, camera.CFrame),
            Enum.BulkMoveMode.FireCFrameChanged
        )
    end

    acrylic.blur.FocusDistance = 0.25 - camera.NearPlaneZ
end

function acrylic.create(frame, shape)
    local part = Instance.new("Part")
    part.Size = Vector3.one * acrylic.partSize
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Material = Enum.Material.Glass
    part.Transparency = acrylic.partTransparency
    part.Parent = workspace.CurrentCamera

    local mesh

    if shape == "Rectangle" then
        mesh = Instance.new("BlockMesh")
    elseif shape == "Oval" then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
    end

    if mesh then
        mesh.Parent = part
    end

    local ignoreInset = false
    local current = frame

    while current do
        current = current.Parent

        if current and current:IsA("ScreenGui") then
            ignoreInset = current.IgnoreGuiInset
            break
        end
    end

    local object = setmetatable({
        frame = frame,
        part = part,
        mesh = mesh,
        ignoreInset = ignoreInset,
    }, acrylic)

    acrylic.objects[object] = part
    acrylic.rebuild()

    return object
end

function acrylic:apply(gui)
    if self.applied[gui] then
        return self.applied[gui]
    end

    if not self.blur then
        self.blur = Instance.new("DepthOfFieldEffect")
        self.blur.FarIntensity = 0
        self.blur.NearIntensity = self.intensity
        self.blur.FocusDistance = 0.25
        self.blur.InFocusRadius = 0
        self.blur.Parent = lighting
    end

    local object = self.create(gui, "Rectangle")

    self.applied[gui] = object

    if not self.connection then
        self.connection = true

        runService:BindToRenderStep(
            "HirimiAcrylic",
            Enum.RenderPriority.Camera.Value + 1,
            function()
                self:update()
            end
        )
    end

    self:update()

    return object
end

function acrylic:setValue(value)
    self.intensity = tonumber(value) or (value and 1 or 0)

    if self.blur then
        self.blur.NearIntensity = self.intensity
    end

    return value
end

function acrylic:destroy(gui)
    if gui then
        local object = self.applied[gui]

        if not object then
            return
        end

        object.part:Destroy()
        self.objects[object] = nil
        self.applied[gui] = nil

        self.rebuild()
        return
    end

    for object in self.objects do
        object.part:Destroy()
    end

    table.clear(self.objects)
    table.clear(self.parts)
    table.clear(self.applied)

    if self.connection then
        runService:UnbindFromRenderStep("HirimiAcrylic")
        self.connection = false
    end

    if self.blur then
        self.blur:Destroy()
        self.blur = nil
    end
end

return acrylic
