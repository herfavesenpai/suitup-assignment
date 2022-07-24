local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local OFFSET_SCALE = 0.66
local HEIGHT_AXIS = "Y"
local BASE_HEIGHT = Vector3.new(
    3.024299621582, 6.5810575485229, 4.010778427124
)[HEIGHT_AXIS]
-- 3.024299621582, 6.5810575485229, 4.010778427124

return function(instance, direction, distance, travel_time, can_float)
    local existingBvelo = instance:FindFirstChild("BodyVelocity")
    if existingBvelo then
        existingBvelo:Destroy()
    end

    local y_force = (can_float and math.huge) or 0
    local heightRatio = 1
    local assembly = instance:FindFirstAncestorOfClass("Model")

    local isPlayer = false
    if RunService:IsClient() then
        local LocalPlayer = game.Players.LocalPlayer
        isPlayer = assembly == LocalPlayer.Character
    end

    if assembly and not isPlayer then
        local size = assembly:WaitForChild("Hitbox").Size
        heightRatio = math.clamp((size[HEIGHT_AXIS] / BASE_HEIGHT) * OFFSET_SCALE,
        1, math.huge)
    end

    local bvelo = Instance.new("BodyVelocity")
    bvelo.MaxForce = Vector3.new(math.huge, y_force, math.huge)
    bvelo.Velocity = direction * (distance/travel_time) * heightRatio
    bvelo.P = 3000
    
    bvelo.Parent = instance

    TweenService:Create(
        bvelo,
        TweenInfo.new(
            travel_time,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        {
            Velocity = Vector3.new()
        }
    ):Play()

    Debris:AddItem(bvelo, travel_time)

    return bvelo
end